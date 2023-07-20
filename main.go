package main

import (
	"context"
	"crypto/rand"
	"crypto/rsa"
	"crypto/x509"
	"crypto/x509/pkix"
	"encoding/json"
	"encoding/pem"
	"fmt"
	"log"
	"math/big"
	"os"
	"time"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/acm"
	"github.com/aws/aws-sdk-go/service/secretsmanager"
)

type CertificateJson struct {
	CommonName       string `json:"common_name"`
	Country          string `json:"country"`
	Email            string `json:"email"`
	Location         string `json:"location"`
	Organization     string `json:"organization"`
	OrganizationUnit string `json:"organization_unit"`
	State            string `json:"state"`
	NotAfter         int    `json:"not_after"`
}

var (
	caCertificateARN = os.Getenv("CA_CERTIFICATE_ARN")
	caKeyArn         = os.Getenv("CA_KEY_ARN")
)

var certJson CertificateJson

func main() {
	lambda.Start(handler)
}

func handler(ctx context.Context, request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	fmt.Println("Test====Line====Test")
	sess, err := session.NewSession(&aws.Config{
		Region: aws.String(os.Getenv("AWS_REGION")),
	})
	if err != nil {
		log.Printf("Error creating session: %v", err)
	}
	caCert := importCACertificate(sess, caCertificateARN)
	caKey := importCaKey(sess, caKeyArn)
	generatedCertBytes, generatedKeyBytes := certGen(request, caCert, caKey)
	genCertArn := uploadCertificate(sess, generatedCertBytes, generatedKeyBytes)

	msg := fmt.Sprintf("Certificate has been succcesfully generated. Its arn: %v. Valid till: %v", genCertArn, time.Now().AddDate(0, 0, certJson.NotAfter))

	msgBytes, err := json.Marshal(msg)
	if err != nil {
		log.Panicln(err)
	}

	resp := events.APIGatewayProxyResponse{
		StatusCode: 200,
		Body:       string(msgBytes),
	}
	return resp, nil
}

func uploadCertificate(sess *session.Session, genCertBytes []byte, genKeyBytes []byte) string {
	certPem := &pem.Block{
		Type:  "CERTIFICATE",
		Bytes: genCertBytes,
	}

	privateKeyPEM := &pem.Block{
		Type:  "RSA PRIVATE KEY",
		Bytes: genKeyBytes,
	}

	svc := acm.New(sess)
	input := &acm.ImportCertificateInput{
		Certificate: pem.EncodeToMemory(certPem),
		PrivateKey:  pem.EncodeToMemory(privateKeyPEM),
	}
	result, err := svc.ImportCertificate(input)
	if err != nil {
		log.Printf("Error importing certificate: %v", err)
	}
	return *result.CertificateArn
}

func importCACertificate(sess *session.Session, arn string) string {
	svc := acm.New(sess)

	input := &acm.GetCertificateInput{
		CertificateArn: aws.String(arn),
	}

	result, err := svc.GetCertificate(input)
	if err != nil {
		log.Panicln(err)
	}
	if result.Certificate == nil {
		log.Panicf("There is no certificate")
	}

	return *result.Certificate
}

func importCaKey(sess *session.Session, caKeyArn string) []byte {
	svc := secretsmanager.New(sess)

	input := &secretsmanager.GetSecretValueInput{
		SecretId: aws.String(caKeyArn),
	}
	result, err := svc.GetSecretValue(input)
	if err != nil {
		panic(err)
	}

	if result.SecretString == nil {
		log.Printf("There is no private secret")
	}

	caKeyBlock, _ := pem.Decode([]byte(*result.SecretString))
	caKey, err := x509.DecryptPEMBlock(caKeyBlock, []byte("test"))
	if err != nil {
		log.Printf("Decrypting private key: Error is %v", err)
	}
	return caKey
}

func certGen(r events.APIGatewayProxyRequest, caCert string, caKeyDerBytes []byte) ([]byte, []byte) {
	err := json.Unmarshal([]byte(r.Body), &certJson)
	if err != nil {
		log.Panicln(err)
	}
	caPrivateKey, err := x509.ParsePKCS1PrivateKey(caKeyDerBytes)
	if err != nil {
		log.Printf("Parsing private key: %v", err)
	}
	caCertPem, _ := pem.Decode([]byte(caCert))
	ca, err := x509.ParseCertificate(caCertPem.Bytes)
	if err != nil {
		log.Printf("Parsing ca cert: %v", err)
	}
	cert := &x509.Certificate{
		SerialNumber: big.NewInt(1658),
		Subject: pkix.Name{
			Organization: []string{certJson.Organization},
			Country:      []string{certJson.Country},
			Locality:     []string{certJson.Location},
			CommonName:   certJson.CommonName,
		},
		NotBefore:    time.Now(),
		NotAfter:     time.Now().AddDate(0, 0, certJson.NotAfter),
		SubjectKeyId: []byte{1, 2, 3, 4, 6},
		KeyUsage:     x509.KeyUsageDigitalSignature,
	}

	certKeys, err := rsa.GenerateKey(rand.Reader, 2048)
	if err != nil {
		log.Printf("Generating keys: %v", err)
	}

	certBytes, err := x509.CreateCertificate(rand.Reader, cert, ca, &certKeys.PublicKey, caPrivateKey)
	if err != nil {
		log.Printf("Generating certificate: %v", err)
	}
	return certBytes, x509.MarshalPKCS1PrivateKey(certKeys)
}
