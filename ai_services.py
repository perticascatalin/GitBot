import os
import json
from crewai import Agent, Task, Crew, Process

def callback_function(output):
    # Do something after the task is completed
    # Example: Send an email to the manager
    print(f"""
        Task completed!
        Task: {output.description}
        Output: {output.raw_output}
    """)

# os.environ["OPENAI_API_KEY"] = "YOUR_API_KEY"
os.environ['OPENAI_MODEL_NAME'] = 'gpt-4o'

agents_file = open('agents.json')
agents = json.load(agents_file)
verbosity = True

# Define your agents with roles and goals
front_end_dev = Agent(
  role='Front End Tech Lead',
  goal=" ".join(agents['front_end_dev']['goal']),
  backstory=" ".join(agents['front_end_dev']['backstory']),
  verbose=verbosity,
  allow_delegation=True,
)

back_end_dev = Agent(
  role='Back End Tech Lead',
  goal=" ".join(agents['back_end_dev']['goal']),
  backstory=" ".join(agents['back_end_dev']['backstory']),
  verbose=verbosity,
  allow_delegation=True,
)

manager = Agent(
    role='Manager',
    goal=" ".join(agents['manager']['goal']),
    backstory=" ".join(agents['manager']['backstory']),
    verbose=verbosity,
    allow_delegation=True,
#     response_template="""<|start_header_id|>assistant<|end_header_id|>

# {{ .Response }}<|eot_id|>"""
)

summary_spacialist = Agent(
    role='Summary Specialist',
    goal=" ".join(agents['summary_specialist']['goal']),
    backstory=" ".join(agents['summary_specialist']['backstory']),
    verbose=verbosity,
    allow_delegation=True,
)

task_instruction = "Take a look at this code diff:"
output_instruction = "A professional code review comment with the guidelines followed in the improvement suggestion, short reasoning and the code diff. At most 3 paragraphs and the code diff."
tasks_file = open('tasks.json')
tasks = json.load(tasks_file)

# Create tasks for your agents
task1 = Task(
  description=task_instruction + " ".join(tasks['task 1']),
  expected_output=output_instruction,
  agent=manager,
  async_execution=True,
#   callback=callback_function
)

task2 = Task(
  description=task_instruction + " ".join(tasks['task 2']),
  expected_output=output_instruction,
  agent=manager,
  async_execution=True,
#   callback=callback_function
)

# Instantiate your crew with a sequential process
crew = Crew(
  agents=[summary_spacialist, manager, front_end_dev, back_end_dev],
  tasks=[task1, task2],
  verbose=2, # You can set it to 1 or 2 to different logging levels
  process = Process.sequential,
  full_output=True,
)

# Get your crew to work!
result = crew.kickoff()

print("######################")
print(result)

# Returns a TaskOutput object with the description and results of the task
print(f"""
    Task 1 completed!
    Task: {task1.output.description}
    Output: {task1.output.raw_output}
""")

# Returns a TaskOutput object with the description and results of the task
print(f"""
    Task 2 completed!
    Task: {task2.output.description}
    Output: {task2.output.raw_output}
""")