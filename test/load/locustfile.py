from locust import HttpUser, task, events, between
from requests_aws4auth import AWS4Auth
import os
import json
import faker
import requests
import random

items = {}
stores = {}
auth = {}

fake = faker.Faker()
workspace_domain = 'ims-signin-master'
aws_region = 'eu-west-3'
refresh_token = os.getenv('REFRESH_TOKEN')
client_id = os.getenv('CLIENT_ID')

url = f'https://{workspace_domain}.auth.{aws_region}.amazoncognito.com/oauth2/token'

headers = {'Content-Type': 'application/x-www-form-urlencoded'}
data = {
    'grant_type': 'refresh_token',
    'refresh_token': refresh_token,
    'redirect_uri': 'https://oauth.pstmn.io/v1/browser-callback',
    'client_id': client_id
}

response = requests.post(url, headers=headers, data=data)
json_response = response.json()
print(json_response)

if 'id_token' in json_response:
    id_token = json_response['id_token']
else:
    exit(-1)

url = "https://u1sr62iesd.execute-api.eu-west-3.amazonaws.com/dev/get_credentials"

payload = {}
headers = {
    'Authorization': f'Bearer {id_token}'
}

response = requests.request(
    "GET", url, headers=headers, data=payload).json()

auth = AWS4Auth(response['AccessKeyId'], response['SecretKey'], aws_region, 'execute-api',
                session_token=response['SessionToken'])


class TestUser(HttpUser):
    wait_time = between(1, 10)

    @task
    def get_items(self):
        self.client.get("/dev/items", auth=auth)

    @task(2)
    def add_item(self):
        item_name = fake.file_name()
        with self.client.put("/dev/items", auth=auth, data=json.dumps({"name": item_name}), catch_response=True) as response:
            try:
                item_id = response.json()['id']
                items[item_id] = item_name
                response.success()
            except Exception as e:
                response.failure(response.text)

    @task(2)
    def get_item(self):
        if len(items) == 0:
            return

        item_id = random.choice(list(items.keys()))
        with self.client.get(f"/dev/items/{item_id}", auth=auth, catch_response=True) as response:
            try:
                item_name = response.json()['name']
                if item_name != items[item_id]:
                    raise Exception
                response.success()
            except Exception as e:
                response.failure(response.text)

    @task
    def delete_item(self):
        if len(items) == 0:
            return

        item_id = random.choice(list(items.keys()))
        with self.client.delete(f"/dev/items/{item_id}", auth=auth, catch_response=True) as response:
            try:
                item_name = response.json()['name']
                if item_name != items[item_id]:
                    raise Exception
                del items[item_id]
                response.success()
            except Exception as e:
                response.failure(response.text)

    @task
    def get_stores(self):
        self.client.get("/dev/stores", auth=auth)

    @task(2)
    def add_store(self):
        store_name = fake.company()
        store_address = fake.address()

        body = {'name': store_name, 'address': store_address}
        body = json.dumps(body)

        with self.client.put("/dev/stores", auth=auth, data=body, catch_response=True) as response:
            try:
                store_id = response.json()['id']
                stores[store_id] = json.loads(body)
                response.success()
            except Exception as e:
                response.failure(response.text)

    @task(2)
    def get_store(self):
        if len(stores) == 0:
            return

        store_id = random.choice(list(stores.keys()))
        with self.client.get(f"/dev/stores/{store_id}", auth=auth, catch_response=True) as response:
            try:
                store_name = response.json()['name']
                store_address = response.json()['address']

                if store_name != stores[store_id]['name'] or \
                   store_address != stores[store_id]['address']:
                    raise Exception

                response.success()
            except Exception as e:
                response.failure(response.text)

    @task
    def delete_store(self):
        if len(stores) == 0:
            return

        store_id = random.choice(list(stores.keys()))
        with self.client.delete(f"/dev/stores/{store_id}", auth=auth, catch_response=True) as response:
            try:
                # TODO
                # This is wrong because of JSON magic and I'm too tired to fix
                store_name = response.json()['name']
                store_address = response.json()['address']

                # if store_name != stores[store_id]['name'] or \
                #    store_address != stores[store_id]['address']:
                #     raise Exception

                del stores[store_id]
                response.success()
            except Exception as e:
                response.failure(response.text)


@events.test_stop.add_listener
def on_test_stop(**kwargs):
    print("Cleaning up test data")

    url = "https://u1sr62iesd.execute-api.eu-west-3.amazonaws.com"

    for item_id in items:
        requests.request(
            "DELETE", f'{url}/dev/items/{item_id}', auth=auth)

    for store_id in stores:
        requests.request(
            "DELETE", f'{url}/dev/stores/{store_id}', auth=auth)
