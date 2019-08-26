class CreateArksRunner < JobRunner
  register_for_job_type('create_arks_job',
                        {:create_permissions => :administer_system,
                         :cancel_permissions => :administer_system})

  def run
    begin

      # RESOURCES
      @job.write_output("Creating ARKs for Resources")
      @job.write_output("================================")

      Resource.any_repo.each do |r|
        if ArkName.count == 0 || ArkName.first(resource_id: r[:id]).nil?
          ArkName.insert(:archival_object_id => nil,
                         :resource_id        => r[:id],
                         :created_by         => 'admin',
                         :last_modified_by   => 'admin',
                         :create_time        => Time.now,
                         :system_mtime       => Time.now,
                         :user_mtime         => Time.now,
                         :lock_version       => 0)
        end
      end

      # Archival Object
      @job.write_output("Creating ARKs for Archival Objects")
      @job.write_output("================================")

      ArchivalObject.any_repo.each do |r|
        if ArkName.count == 0 || ArkName.first(archival_object_id: r[:id]).nil?
          ArkName.insert(:archival_object_id => r[:id],
                         :resource_id        => nil,
                         :created_by         => 'admin',
                         :last_modified_by   => 'admin',
                         :create_time        => Time.now,
                         :system_mtime       => Time.now,
                         :user_mtime         => Time.now,
                         :lock_version       => 0)
        end
      end

      self.success!
    rescue Exception => e
      @job.write_output(e.message)
      @job.write_output(e.backtrace)
      raise e
    end
  end
end
