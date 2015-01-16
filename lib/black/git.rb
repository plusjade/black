require './diff'

module Black
  module Git
    # wrapper to execute git in the shell.
    # Reimplement this to suit your own platform needs
    def self.execute(path, *command_args)
      FileUtils.cd(path) do
        return `git #{ command_args.join(' ') } --no-color`
      end
    end

    class Repository
      def initialize(path)
        unless File.directory?(path)
          raise "#{ path } is not a valid directory"
        end

        @path = path
      end

      def commits
        Enumerator.new do |y|
          commits_dict.each_key do |index|
            y.yield commit_at(index)
          end
        end
      end

      # Return a diff object for each file in the given commit
      def commit_at(index_or_sha)
        if index_or_sha.is_a?(Integer)
          index = index_or_sha
          sha = commits_dict[index_or_sha]
        else
          index = commits_dict.key(index_or_sha)
          sha = index_or_sha
        end
        sha_previous = commits_dict[index-1]
        output = diff_output(sha)

        commands = %w(diff-tree --no-commit-id --name-status -r)
        commands.push('--root') if index.zero?
        commands.push(sha)

        Black::Git
          .execute(@path, commands)
          .lines
          .map
          .with_index do |line, i|
            status, filename = line.split(/\s+/)
            status = status.chomp
            filename = filename.chomp

            Black::Git::Diff.new(@path, sha, sha_previous, output[i], filename, status)
          end
      end

      # Store a lookup dictionary for all commits
      def commits_dict
        return @commits_dict if @commits_dict

        @commits_dict = {}
        Black::Git
          .execute(@path, %w(rev-list HEAD --reverse))
          .each_line
          .with_index{ |a, i| @commits_dict[i] = a.chomp }

        @commits_dict
      end

      # Get diff output on all files in each commit rather than one file at a time.
      def diff_output(sha)
        output = []
        marker = 0

        Black::Git
          .execute(@path, %w(show --format='%b' --no-prefix -U1000).push(sha))
          .each_line do |line|
            if line.start_with?('diff --git')
              marker += 1
            else
              if output[marker]
                output[marker] += line
              else
                output[marker] = line
              end
            end
          end

        # there are two empty lines at the top of the git show output
        output.shift
        output
      end
    end

    class Diff
      include Enumerable

      attr_reader :older, :newer, :filename, :status

      def initialize(path, sha, sha_previous, diff_output, filename, status)
        @path = path
        @sha = sha
        @sha_previous = sha_previous
        @diff_output = diff_output
        @filename = filename
        @status = status
      end

      def each
        if block_given?
          diff_parsed.each do |line|
            yield line
          end
        else
          diff_parsed.enum_for(:each) 
        end
      end

      def newer
        @newer ||= Black::Git.execute(@path, "show", "#{ @sha }:#{ @filename }")
      end

      def older
        @older ||= Black::Git.execute(@path, "show", "#{ @sha_previous }:#{ @filename }")
      end

      def diff_parsed
        Black::Diff::OutputParser.parse(@diff_output.enum_for(:lines))
      end
    end
  end
end
