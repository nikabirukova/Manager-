require 'minitest/autorun'
require_relative 'task_manager'

class TestTaskManager < Minitest::Test
  def setup
    # Очищення тестового файлу
    File.write('test_tasks.json', '[]')
    @task_manager = TaskManager.new('test_tasks.json')

    # Додавання задач
    @task_manager.add_task('Task 1', 'Description 1', '2024-12-01')
    @task_manager.add_task('Task 2', 'Description 2', '2024-12-05', 'Completed')
  end

  def test_add_task
    @task_manager.add_task('Task 3', 'Description 3', '2024-12-10')
    assert_equal 3, @task_manager.filter_tasks.length
  end

  def test_remove_task
    @task_manager.remove_task('Task 1')
    assert_equal 1, @task_manager.filter_tasks.length
  end

  def test_edit_task
    @task_manager.edit_task('Task 2', 'Updated Task 2', nil, nil, 'In Progress')
    task = @task_manager.filter_tasks(status: 'In Progress').first
    assert task, 'Task should not be nil'
    assert_equal 'Updated Task 2', task.title
    assert_equal 'In Progress', task.status
  end

  def test_filter_tasks
    tasks = @task_manager.filter_tasks(before_date: '2024-12-04')
    assert_equal 1, tasks.length
  end

  def test_save_and_load_tasks
    @task_manager.add_task('Task 4', 'Description 4', '2024-12-20')
    @task_manager.save_tasks
    new_manager = TaskManager.new('test_tasks.json')
    assert_equal 3, new_manager.filter_tasks.length
  end
end
