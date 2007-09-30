SRC_DIR = File.expand_path(pwd + '/src')
BASE_FILE = 'base'
PROJECT_FILE = File.basename(pwd)
TMP_FILES = %w(aux bbl blg log lot lof toc)
GEN_FILES = %w(dvi ps pdf)

task :default => :compile

desc 'Compiles source files with latex and bibtex'
task :compile do
  cd(SRC_DIR) do
    system "latex #{BASE_FILE}"
    if FileList['*.bib'].size > 0
      system "bibtex #{BASE_FILE}"
      system "latex #{BASE_FILE}"
    end
    system "latex #{BASE_FILE}"
  end
end

namespace :compile do

  desc 'Compiles source files into dvi format'
  task :dvi => :compile do
    mv_file(:dvi)
  end

  desc 'Compiles source files into ps format'
  task :ps => :compile do
    cd(SRC_DIR) do
      system "dvips #{BASE_FILE}"
    end
    mv_file(:ps)
  end

  desc 'Compiles source files into pdf format'
  task :pdf => :compile do
    cd(SRC_DIR) do
      system "pdflatex #{BASE_FILE}"
    end
    mv_file(:pdf)
  end
end

desc 'View compiled file'
task :view => 'view:dvi'

namespace :view do

  desc 'View compiled file in dvi format'
  task :dvi => 'compile:dvi'do
    view_file(:dvi)
  end

  desc 'View compiled file in ps format'
  task :ps => 'compile:ps' do
    view_file(:ps)
  end

  desc 'View compiled file in pdf format'
  task :pdf => 'compile:pdf' do
    view_file(:pdf)
  end
end

desc 'Spell check source files'
task :spell do
  # TODO: use ispell -t
end

desc 'Generate a statistical report'
task :report do
  print_stats(FileList["#{SRC_DIR}/*.tex"])
  # TODO: word count: total, per chapter, with and without appendix
end

desc "Cleans up temporary files (#{TMP_FILES.join(' ')})"
task :clean do
  cd(SRC_DIR) do
    TMP_FILES.each do |tmp_file|
      rm_f FileList["*.#{tmp_file}"]
    end
  end
end

desc "Cleans up explicitly created files (#{GEN_FILES.join(' ')})"
task :clobber => :clean do
  GEN_FILES.each do |gen_file|
    rm_f FileList["#{PROJECT_FILE}.#{gen_file}"]
  end
end

private
  def mv_file(format)
    mv(File.join(SRC_DIR, "#{BASE_FILE}.#{format.to_s}"),
       File.join(pwd, "/#{PROJECT_NAME}"))
  end

  def view_file(format)
    viewers = case format
              when :dvi
                %w(dviprog xdvi)
              when :ps
                %w(psprog evince acroread)
              when :pdf
                %w(kpdf evince acroread)
              end
    viewers.each do |viewer|
      if system "which #{viewer}"
        system "#{viewer} #{PROJECT_NAME}.#{format.to_s}"
        return
      end
    end
  end

  def print_stats(files)
    print_stat_splitter
    print_stat_header
    print_stat_splitter
    files.each do |file|
      stats = {}
      out = `wc -w #{file}`
      stats[:total_wc] = out.to_s.split[0].to_i
      stats[:textual_wc] = (stats[:total_wc] * 0.7).to_i
      stats[:latex_wc] = stats[:total_wc] - stats[:textual_wc]
      stats[:textual_percentage] = stats[:textual_wc] * 100 / stats[:total_wc]
      print_stat_line(File.basename(file), stats)
    end
    print_stat_splitter
  end

  def print_stat_line(name, stats)
    puts "| #{name.ljust(40)}" +
         "| #{stats[:total_wc].to_s.rjust(8)}" +
         "| #{stats[:textual_wc].to_s.rjust(8)}" +
         "| #{stats[:latex_wc].to_s.rjust(8)}" +
         "| #{stats[:textual_percentage].to_s.rjust(8)} |"
  end

  def print_stat_header
    stats = {}
    stats[:total_wc]           = 'Total'
    stats[:textual_wc]         = 'Textual'
    stats[:latex_wc]           = 'LaTeX'
    stats[:textual_percentage] = 'Text %'
    print_stat_line('Filename', stats)
  end

  def print_stat_splitter
    puts '+' + '-'*32 + ('-'*9 + '+') * 4 + '-'*10 + '+'
  end
