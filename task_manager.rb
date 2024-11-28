require 'json'
require 'date'

class Task
  attr_accessor :title, :description, :deadline, :status

  def initialize(title, description, deadline, status = 'Pending')
    @title = title
    @description = description
    @deadline = Date.parse(deadline)
    @status = status
  end

  def to_h
    {
      title: @title,
      description: @description,
      deadline: @deadline.to_s,
      status: @status
    }
  end
end

class TaskManager
  def initialize(file_path = 'tasks.json')
    @file_path = file_path
    @tasks = load_tasks
  end

  def add_task(title, description, deadline, status = 'Pending')
    @tasks << Task.new(title, description, deadline, status)
    save_tasks
  end

  def remove_task(title)
    @tasks.reject! { |task| task.title == title }
    save_tasks
  end

  def edit_task(title, new_title = nil, new_description = nil, new_deadline = nil, new_status = nil)
    task = @tasks.find { |t| t.title == title }
    return unless task

    task.title = new_title if new_title
    task.description = new_description if new_description
    task.deadline = Date.parse(new_deadline) if new_deadline
    task.status = new_status if new_status
    save_tasks
  end

  def filter_tasks(status: nil, before_date: nil, after_date: nil)
    filtered_tasks = @tasks.dup

    filtered_tasks.select! { |task| task.status == status } if status
    filtered_tasks.select! { |task| task.deadline < Date.parse(before_date) } if before_date
    filtered_tasks.select! { |task| task.deadline > Date.parse(after_date) } if after_date

    filtered_tasks
  end

  def save_tasks
    File.write(@file_path, JSON.pretty_generate(@tasks.map(&:to_h)))
  end

  def load_tasks
    return [] unless File.exist?(@file_path)

    JSON.parse(File.read(@file_path), symbolize_names: true).map do |task_data|
      Task.new(task_data[:title], task_data[:description], task_data[:deadline], task_data[:status])
    end
  end
end

# Інтерактивна частина
manager = TaskManager.new

loop do
  puts "\nTask Manager Menu:"
  puts "1. Add Task"
  puts "2. Remove Task"
  puts "3. Edit Task"
  puts "4. Show All Tasks"
  puts "5. Filter Tasks"
  puts "6. Exit"
  print "Choose an option: "

  choice = gets.chomp.to_i

  case choice
  when 1
    print "Enter title: "
    title = gets.chomp
    print "Enter description: "
    description = gets.chomp
    print "Enter deadline (YYYY-MM-DD): "
    deadline = gets.chomp
    print "Enter status (Pending/Completed): "
    status = gets.chomp
    manager.add_task(title, description, deadline, status)
    puts "Task added successfully!"

  when 2
    print "Enter the title of the task to remove: "
    title = gets.chomp
    manager.remove_task(title)
    puts "Task removed successfully!"

  when 3
    print "Enter the title of the task to edit: "
    title = gets.chomp
    print "Enter new title (or press Enter to skip): "
    new_title = gets.chomp
    new_title = nil if new_title.empty?
    print "Enter new description (or press Enter to skip): "
    new_description = gets.chomp
    new_description = nil if new_description.empty?
    print "Enter new deadline (YYYY-MM-DD) (or press Enter to skip): "
    new_deadline = gets.chomp
    new_deadline = nil if new_deadline.empty?
    print "Enter new status (Pending/Completed) (or press Enter to skip): "
    new_status = gets.chomp
    new_status = nil if new_status.empty?
    manager.edit_task(title, new_title, new_description, new_deadline, new_status)
    puts "Task edited successfully!"

  when 4
    puts "\nAll tasks:"
    manager.filter_tasks.each do |task|
      puts "#{task.title} (#{task.status}) - Deadline: #{task.deadline}"
    end

  when 5
    print "Filter by status (Pending/Completed or press Enter to skip): "
    status = gets.chomp
    status = nil if status.empty?
    print "Filter by deadline before (YYYY-MM-DD or press Enter to skip): "
    before_date = gets.chomp
    before_date = nil if before_date.empty?
    print "Filter by deadline after (YYYY-MM-DD or press Enter to skip): "
    after_date = gets.chomp
    after_date = nil if after_date.empty?

    tasks = manager.filter_tasks(status: status, before_date: before_date, after_date: after_date)
    puts "\nFiltered tasks:"
    tasks.each do |task|
      puts "#{task.title} (#{task.status}) - Deadline: #{task.deadline}"
    end

  when 6
    puts "Exiting Task Manager. Goodbye!"
    break

  else
    puts "Invalid option. Please try again."
  end
end
