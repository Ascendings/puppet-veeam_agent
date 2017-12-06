require File.expand_path(File.join(File.dirname(__FILE__), '..', 'veeam'))
Puppet::Type.type(:veeam_schedule).provide(:veeam, :parent => Puppet::Provider::Veeam) do
  desc "Veeam backup schedule management"

  # instance variable to hold the job's ID (determined from the job name)
  @job_id = ''

  def create
    # check if the job exists first - veeamconfig will throw a hisy fit if the
    #   schedule already exists
    if not alive?
      if @resource[:weekdays].include? 'daily' or @resource[:weekdays].include? :daily
        veeamconfig('schedule', 'set', '--jobId', get_job_id, '--daily', '--at', "#{@resource[:time]}")
      else
        wd = @resource[:weekdays].join(',')
        veeamconfig('schedule', 'set', '--jobId', get_job_id, '--weekdays', "#{wd}", '--at', "#{@resource[:time]}")
      end
    end

    veeamconfig('schedule', 'enable', '--jobId', get_job_id)
  end

  def destroy
    veeamconfig('schedule', 'disable', '--jobId', get_job_id)
  end

  def exists?
    begin
      result = veeamconfig('schedule', 'show', '--jobId', get_job_id).lines
      # we will also want to check if the job is enabled
      return result[2].strip == 'Run automatically: enabled'
    rescue
      # veeamconfig will throw a hissy fit and force Puppet to fail if the jobId
      #   doesn't exist
      false
    end
  end

  # return the schedule's weekdays
  def weekdays
    result = veeamconfig('schedule', 'show', '--jobId', get_job_id).lines
    # get an array of days
    wd = result[0].strip.split(': ')[1].split(', ')

    # if the array of weekdays is 7, this means that every day has a backup, so
    #   we should, instead, use daily
    if wd.length == 7
      ['daily']
    else
      wd
    end
  end

  # set the schedule's weekdays
  def weekdays=(value)
    # check if the weekdays property contains 'daily' - this will override any
    #   other days that have been set
    if value.include? :daily or value.include? 'daily'
      veeamconfig('schedule', 'set', '--jobId', get_job_id, '--daily', '--at', "#{@resource[:time]}")
    else
      wd = value.join(',')
      veeamconfig('schedule', 'set', '--jobId', get_job_id, '--weekdays', "#{wd}", '--at', "#{@resource[:time]}")
    end
  end

  # return the schedule's begin time
  def time
    result = veeamconfig('schedule', 'show', '--jobId', get_job_id).lines
    # get the time
    t = result[1].strip.split(': ')[1]
    # split hours and minutes (will use these to pad first)
    bits = t.split(':')
    # pad both the hour and the minute with a zero if needed
    bits[0] = "%02d" % bits[0]
    bits[1] = "%02d" % bits[1]

    # return the joined value (HH:MM)
    bits.join(':')
  end

  # set the schedule's begin time
  def time=(value)
    # check if the weekdays property contains 'daily' - this will override any
    #   other days that have been set
    if @resource[:weekdays].include? :daily or @resource[:weekdays].include? 'daily'
      veeamconfig('schedule', 'set', '--jobId', get_job_id, '--daily', '--at', "#{value}")
    else
      wd = @resource[:weekdays].join(',')
      veeamconfig('schedule', 'set', '--jobId', get_job_id, '--weekdays', "#{wd}", '--at', "#{value}")
    end
  end


  ## Helper functions
  # returns the a backup job ID from the job name
  def get_job_id
    # check if the job ID has already been set (the job name will not change
    #   during execution, so it is safe to assume that the job ID won't change)
    if not defined? @job_id or @job_id == '' or @job_id == nil
      result = veeamconfig('job', 'list').lines
      if result.length > 1
        result.each_with_index do |line, index|
          # skip the first line of output, since it is just the table setup
          next if index == 0

          # split line into array by space
          bits = line.split(' ')
          # pull out the repository name
          job_name = bits[0]

          # parse and return the job ID
          @job_id = bits[1].tr('{}', '') if job_name == @resource[:job_name]
          return @job_id
        end

        # return false if the job doesn't exist
        false
      else
        # return false if there are no jobs that exist
        false
      end
    else
      # return the job ID if it's already set
      @job_id
    end
  end

  # checks only if the schedule has been created
  def alive?
    begin
      result = veeamconfig('schedule', 'show', '--jobId', get_job_id).lines
      # return true if the result doesn't begin with Error
      return (not result[0].strip().begin_with? 'Error')
    rescue
      # veeamconfig will throw a hissy fit if the job doesn't exist
      false
    end
  end
end
