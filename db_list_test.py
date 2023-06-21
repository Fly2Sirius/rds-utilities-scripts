#!/usr/bin/env python3
import boto3
import sys
import os
import json
import funcs as f

if len(sys.argv) > 1:
    username = sys.argv[1]
else:
    print("You must supply a username: createUser username")
    sys.exit()

instance_list = f.get_endpoint_value_by_key("EndpointType","WRITER")

print(instance_list)