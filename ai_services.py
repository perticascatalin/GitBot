import os
import json
from crewai import Agent, Task, Crew, Process

# os.environ["OPENAI_API_KEY"] = "YOUR_API_KEY"
os.environ['OPENAI_MODEL_NAME'] = 'gpt-4o'

agents_file = open('agents.json')
agents = json.load(agents_file)

# Define your agents with roles and goals
front_end_dev = Agent(
  role='Front End Tech Lead',
  goal=" ".join(agents['front_end_dev']['goal']),
  backstory=" ".join(agents['front_end_dev']['backstory']),
  verbose=True,
  allow_delegation=True,
)

back_end_dev = Agent(
  role='Back End Tech Lead',
  goal=" ".join(agents['back_end_dev']['goal']),
  backstory=" ".join(agents['back_end_dev']['backstory']),
  verbose=True,
  allow_delegation=True,
)

manager = Agent(
    role='Manager',
    goal=" ".join(agents['manager']['goal']),
    backstory=" ".join(agents['manager']['backstory']),
    verbose=True,
    allow_delegation=True,
)

summary_spacialist = Agent(
    role='Summary Specialist',
    goal=" ".join(agents['summary_specialist']['goal']),
    backstory=" ".join(agents['summary_specialist']['backstory']),
    verbose=True,
    allow_delegation=True,
)

common_text = "Order of workers manager > devs > manager > summary specialist. Take a look at this diff:"
tasks_file = open('tasks.json')
tasks = json.load(tasks_file)

# Create tasks for your agents
task1 = Task(
  description=common_text + " ".join(tasks['task 1']),
  expected_output="A professional code review comment with the guidelines followed in the improvement suggestion, short reasoning and the code diff. At most 2 paragraphs and the code diff. Summary specialist should provide the final answer",
  agent=manager,
  async_execution=True
)

task2 = Task(
  description=common_text + " ".join(tasks['task 2']),
  expected_output="A professional code review comment with the guidelines followed in the improvement suggestion, short reasoning and the code diff. At most 2 paragraphs and the code diff. Summary specialist should provide the final answer",
  agent=manager,
  async_execution=True
)

# Instantiate your crew with a sequential process
crew = Crew(
  agents=[summary_spacialist, manager, front_end_dev, back_end_dev],
  tasks=[task1, task2],
  verbose=2, # You can set it to 1 or 2 to different logging levels
  process = Process.sequential
)

# Get your crew to work!
result = crew.kickoff()

print("######################")
print(result)