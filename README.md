# x.509 Certificate Generation Service

## 1. Architecture Overview

The x.509 Certificate Generation Service is designed to issue x.509 certificates with a validity period of days client with to have for the Company's applications. The service is built on AWS (Amazon Web Services) to ensure scalability, high availability, and multi-region support.

The architecture consists of the following components:

- **Route53 with Geolocation Policies:** Route53 is used to route traffic from clients around the world to the nearest regional entry point (API Gateway) based on geolocation policies.

- **API Gateway (Europe and America):** API Gateway instances are set up in European and American regions to process incoming requests and trigger the corresponding Lambda function for certificate generation.

- **Go-based Lambda Function:** The Lambda function, written in Go, interacts with AWS Certificate Manager (ACM) to generate x.509 certificates for clients in the respective regions.

- **AWS Certificate Manager (ACM):** ACM manages the creation and lifecycle of the x.509 certificates for clients, ensuring they have valid certificates during their limited license period.

- **AWS Secrets Manager:** Important service data and configurations are stored securely in AWS Secrets Manager.

## 2. Terraform Configuration for AWS

To deploy the x.509 Certificate Generation Service in AWS, use the provided Terraform configuration. The Terraform configuration will provision the necessary infrastructure components, Lambda functions, Route53 records.
## 3. High Availability and Fault Tolerance

The service is designed to be highly available and fault-tolerant by implementing the following strategies:

- **Multiple API Gateway Instances:** API Gateway instances are deployed in both European and American regions, ensuring redundancy and availability even if one region experiences issues.

- **Health Checks and Geolocation Routing:** Route53 performs health checks on the API Gateway instances, and geolocation policies ensure traffic is routed to healthy instances in the nearest region.
## 4. Scalability

The service is designed to scale easily to handle increasing loads. Vertical scaling can be achieved by increasing Lambda function memory allocation. Horizontal scaling can be achieved by adding more API Gateway instances.
## 5. Multi-Region Support

By utilizing Route53's geolocation routing, the service provides low-latency access to clients from different regions. Clients are automatically routed to the nearest API Gateway instance for certificate generation, ensuring a smooth and responsive experience for clients in North America and Europe.

# How to Use? 

Create a JSON request body with the required parameters for certificate generation. The following parameters are mandatory:

- **common_name:** The common name for the certificate.
- **country:** The country code for the organization.
- **email:** The email address of the certificate owner.
- **location:** The location (city or locality) of the organization.
- **not_after:** The validity period of the certificate in days (365 days in this example).

Optional parameters include:

- **organization:** The organization name.
- **organization_unit:** The organizational unit name.
- **state:** The state or province of the organization.


curl --request POST --url https://api.jb.wh1sk.one/certgen --header 'content-type: application/json' --data '{"common_name": "from_curl","country": "curl","email": "curl@example.com","location": "curl","organization": "string","organization_unit": "string","not_after": 365}'


### Example of use

https://jumpshare.com/v/LZa0pfszq8nEFYgcF74w

### Architecture diagram 

[diagram](./assets/Architecture_Diagram.png)
