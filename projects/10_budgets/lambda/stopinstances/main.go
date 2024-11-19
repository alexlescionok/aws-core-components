package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/ec2"
	"github.com/aws/aws-sdk-go-v2/service/ec2/types"
	"github.com/aws/aws-sdk-go/aws"
)

var (
	ec2Client *ec2.Client
)

func init() {
	cfg, err := config.LoadDefaultConfig(context.TODO())
	if err != nil {
		log.Fatalf("unable to load SDK config, %v", err)
	}

	ec2Client = ec2.NewFromConfig(cfg)
}

func handleRequest(ctx context.Context, event json.RawMessage) error {
	describe_params := &ec2.DescribeInstancesInput{
		Filters: []types.Filter{
			{
				Name:   aws.String("instance-state-name"),
				Values: []string{"running"},
			},
		},
	}

	// Describe Instances
	result, err := ec2Client.DescribeInstances(ctx, describe_params)
	if err != nil {
		fmt.Println("Error", err)
	}

	running_instances := []string{}
	for _, reservation := range result.Reservations {
		for _, instance := range reservation.Instances {
			running_instances = append(running_instances, *instance.InstanceId)
		}
	}
	fmt.Println("Running Instances: ", running_instances)

	// Stop Instances
	for _, instance := range running_instances {
		stop_params := &ec2.StopInstancesInput{
			InstanceIds: []string{instance},
		}

		_, err := ec2Client.StopInstances(ctx, stop_params)
		if err != nil {
			fmt.Printf("Failed to stop instance %s: %v\n", instance, err)
		} else {
			fmt.Printf("Successfully stopped instance: %s", instance)
		}
	}

	return nil
}

func main() {
	lambda.Start(handleRequest)
}
