from django.test import TestCase
from . import tasks

class TaskTestCase(TestCase):
    def test_task(self):
        assert tasks.example_task.run(1)
        assert tasks.example_task.run(2)
        assert tasks.example_task.run(3)