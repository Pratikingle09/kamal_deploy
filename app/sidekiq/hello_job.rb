class HelloJob
  include Sidekiq::Job

  def perform(*args)
    # Do something
    puts "job completed successfully"
  end
end
