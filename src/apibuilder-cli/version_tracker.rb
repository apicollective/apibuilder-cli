module ApibuilderCli

  # Records, per organization and application, the concrete service version that
  # `apibuilder update` last generated code from. This makes code currency queryable
  # as data: generated files themselves are not rewritten when only their comments
  # change (see Update#different?), so the "Service version" headers inside them can
  # be arbitrarily older than the version the code actually reflects.
  #
  # Stored in .apibuilder/.tracked_versions, separate from .tracked_files, because
  # that file's top-level YAML keys are organization names: older CLI versions
  # iterating an unrecognized top-level key there would fail.
  class VersionTracker

    def VersionTracker.default_path(project_dir)
      Util.file_join(project_dir, ApibuilderCli::Config::APIBUILDER_LOCAL_DIR, ".tracked_versions")
    end

    # Options:
    #   :path => Mostly here for injecting test config
    def initialize(project_dir, opts={})
      @project_dir = Preconditions.check_not_blank(project_dir, "ERROR: Missing project_dir")
      @path = Preconditions.assert_class(opts.delete(:path) || VersionTracker.default_path(@project_dir), String)
      @versions = {}
      if File.exist?(@path)
        contents = IO.read(@path).strip
        if contents != ""
          @versions = begin
                        Preconditions.assert_class(YAML.load(contents), Hash)
                      rescue StandardError => e
                        # This file is derived data; a corrupt copy is rebuilt on the next update
                        puts "WARNING: Ignoring unparseable file at #{@path}:\n  #{e}"
                        {}
                      end
        end
      end
    end

    def set!(org, application, version)
      Preconditions.check_not_blank(org, "ERROR: Missing org")
      Preconditions.check_not_blank(application, "ERROR: Missing application")
      Preconditions.check_not_blank(version, "ERROR: Missing version")
      (@versions[org] ||= {})[application] = version
    end

    def version(org, application)
      Preconditions.check_not_blank(org, "ERROR: Missing org")
      Preconditions.check_not_blank(application, "ERROR: Missing application")
      (@versions[org] || {})[application]
    end

    # Saves the tracked version map, sorted for deterministic output
    def save!
      output = {}
      @versions.keys.sort.each do |org|
        next if @versions[org].empty?
        output[org] = {}
        @versions[org].keys.sort.each do |application|
          output[org][application] = @versions[org][application]
        end
      end
      File.open(@path, "w") do |out|
        out << output.to_yaml
      end
    end

  end

end
