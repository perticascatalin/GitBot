import os
import json
import pdb
from flask import Flask, request, jsonify
from crewai import Agent, Task, Crew, Process

# os.environ["OPENAI_API_KEY"] = "YOUR_API_KEY"
os.environ['OPENAI_MODEL_NAME'] = 'gpt-4o'

def callback_function(output):
    # Do something after the task is completed
    # Example: Send an email to the manager
    print(f"""
        Task completed!
        Task: {output.description}
        Output: {output.raw_output}
    """)

def read_files_in_directory(directory_path):
    all_files_content = []

    # List all files in the specified directory
    for filename in os.listdir(directory_path):
        file_path = os.path.join(directory_path, filename)

        # Check if the file path is a file (not a directory)
        if os.path.isfile(file_path):
            with open(file_path, 'r') as file:
                # Read the content of the file
                file_content = file.read()
                # Append the content to the list
                all_files_content.append(file_content)

    return all_files_content

def run_experiment(hunks):
    agents_file = open('agents.json')
    agents = json.load(agents_file)
    verbosity = True

    # Define your agents with roles and goals
    front_end_dev = Agent(
        role='Front End Tech Lead',
        goal=" ".join(agents['front_end_dev']['goal']),
        backstory=" ".join(agents['front_end_dev']['backstory']),
        verbose=verbosity,
        allow_delegation=True
    )

    back_end_dev = Agent(
        role='Back End Tech Lead',
        goal=" ".join(agents['back_end_dev']['goal']),
        backstory=" ".join(agents['back_end_dev']['backstory']),
        verbose=verbosity,
        allow_delegation=True
    )

    manager = Agent(
        role='Manager',
        goal=" ".join(agents['manager']['goal']),
        backstory=" ".join(agents['manager']['backstory']),
        verbose=verbosity,
        allow_delegation=True
    )

    summary_spacialist = Agent(
        role='Summary Specialist',
        goal=" ".join(agents['summary_specialist']['goal']),
        backstory=" ".join(agents['summary_specialist']['backstory']),
        verbose=verbosity,
        allow_delegation=True
    )

    task_instruction = "Take a look at this code diff:"
    output_instruction = "A professional code review comment with the guidelines followed in the improvement suggestion, short reasoning and the code diff. At most 3 paragraphs and the code diff."

    tasks = []

    # Print the array of file contents
    for i, content in enumerate(hunks):
        print(f"Content of file {i + 1}:\n{content}\n")
        new_task = Task(
            description=task_instruction + content,
            expected_output=output_instruction,
            agent=manager,
            async_execution=False,
            # callback=callback_function
        )
        tasks.append(new_task)


    # Instantiate your crew with a sequential process
    crew = Crew(
        agents=[summary_spacialist, manager, front_end_dev, back_end_dev],
        tasks=tasks,
        verbose=2, # You can set it to 1 or 2 to different logging levels
        process = Process.sequential,
        full_output=True,
    )


    # Get your crew to work!
    result = crew.kickoff()

    print("######################")
    print(result)

    for i, task in enumerate(crew.tasks):
        print(f"""
            Task {i + 1} completed!
            Task: {task.output.description}
            Output: {task.output.raw_output}
        """)

    return crew.tasks

app = Flask(__name__)

@app.route('/', methods=['GET'])
def handle_get():
    return "Hello, World! This is a GET request."

@app.route('/', methods=['POST'])
def handle_post():
    data = request.json
    print(data)
    hunks = list(data.values())
    return_data = run_experiment(hunks)
    dict = {}
    for i, task in enumerate(return_data):
        dict[i] = task.output.raw_output

    return_dict = json.dumps(dict)
    return jsonify({
        "message": "Hello, World! This is a POST request.",
        "received_data": return_dict
    })

if __name__ == '__main__':
    app.run(port=8000)

# # Specify the directory path
# directory_path = './samples'

# # Get the concatenated content of all files in the directory
# hunks = read_files_in_directory(directory_path)

# return_data = run_experiment(hunks)

# breakpoint()
# dict = {}
# for i, task in enumerate(return_data):
#     dict[i] = task.output.raw_output

# return_dict = json.dumps(dict)