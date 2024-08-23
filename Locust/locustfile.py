from locust import HttpUser, TaskSet, task, between

class UserBehavior(TaskSet):
    
    @task
    def get_stock_data(self):
        self.client.get("/")

class WebsiteUser(HttpUser):
    tasks = [UserBehavior]
    wait_time = between(1, 5)