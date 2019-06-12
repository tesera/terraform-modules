#####################################################################################################################
# Copyright 2019 Amazon.com, Inc. or its affiliates. All Rights Reserved.                                           #
#                                                                                                                   #
# Licensed under the Amazon Software License (the "License"). You may not use this file except in compliance        #
# with the License. A copy of the License is located at                                                             #
#                                                                                                                   #
#     http://aws.amazon.com/asl/                                                                                    #
#                                                                                                                   #
# or in the "license" file accompanying this file. This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES #
# OR CONDITIONS OF ANY KIND, express or implied. See the License for the specific language governing permissions    #
# and limitations under the License.                                                                                #
######################################################################################################################

import boto3
import json
import logging
import math
import time
import datetime
from urllib.request import Request, urlopen
from os import environ
from ipaddress import ip_address
from botocore.config import Config

logging.getLogger().debug('Loading function')

#======================================================================================================================
# Constants
#======================================================================================================================
API_CALL_NUM_RETRIES = 5

waf = None

#======================================================================================================================
# Auxiliary Functions
#======================================================================================================================
def waf_update_ip_set(ip_set_id, source_ip):
    logging.getLogger().debug('[waf_update_ip_set] Start')

    ip_type = "IPV%s"%ip_address(source_ip).version
    ip_class = "32" if ip_type == "IPV4" else "128"
    waf.update_ip_set(IPSetId=ip_set_id,
        ChangeToken=waf.get_change_token()['ChangeToken'],
        Updates=[{
            'Action': 'INSERT',
            'IPSetDescriptor': {
                'Type': ip_type,
                'Value': "%s/%s"%(source_ip, ip_class)
            }
        }]
    )

    logging.getLogger().debug('[waf_update_ip_set] End')

def waf_get_ip_set(ip_set_id):
    logging.getLogger().debug('[waf_get_ip_set] Start')
    response = waf.get_ip_set(IPSetId=ip_set_id)
    logging.getLogger().debug('[waf_get_ip_set] End')
    return response

#======================================================================================================================
# Lambda Entry Point
#======================================================================================================================
def lambda_handler(event, context):
    logging.getLogger().debug('[lambda_handler] Start')

    response = {
        'statusCode': 200,
        'headers': {'Content-Type': 'application/json'},
        'body': ''
    }

    try:
        #------------------------------------------------------------------
        # Set Log Level
        #------------------------------------------------------------------
        global log_level
        log_level = str(environ['LOG_LEVEL'].upper())
        if log_level not in ['DEBUG', 'INFO','WARNING', 'ERROR','CRITICAL']:
            log_level = 'ERROR'
        logging.getLogger().setLevel(log_level)

        #----------------------------------------------------------
        # Read inputs parameters
        #----------------------------------------------------------
        logging.getLogger().info(event)
        source_ip = event['headers']['X-Forwarded-For'].split(',')[0].strip()

        global waf
        if environ['LOG_TYPE'] == 'regional':
            session = boto3.session.Session(region_name=environ['REGION'])
            waf = session.client('waf-regional', config=Config(retries={'max_attempts': API_CALL_NUM_RETRIES}))
        else:
            waf = boto3.client('waf', config=Config(retries={'max_attempts': API_CALL_NUM_RETRIES}))

        waf_update_ip_set(environ['IP_SET_ID_BAD_BOT'], source_ip)

        message = {}
        message['message'] = "[%s] Thanks for the visit."%source_ip
        response['body'] = json.dumps(message)

    except Exception as error:
        logging.getLogger().error(str(error))

    logging.getLogger().debug('[lambda_handler] End')
    return response
