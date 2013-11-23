require 'sinatra'
require 'flog'

get '/' do
  erb :index
end

post '/validate' do
  "# Flog: #{flog_it} - #{Time.now}
#{a_msg_from_Sandi}
------------------\n"
end

def a_msg_from_Sandi
  return if sandi_it.length == 0
  "\n# Long methods: #{sandi_it}"
end

def flog_it
  f = Flog.new
  f.flog_ruby params[:code]
  f.calculate_total_scores
  f.total_score.to_s.to_f.round.to_s
rescue RubyParser::SyntaxError, Racc::ParseError => e
  'RUBY, Y U NO RUN'
end


require 'sandi_meter/file_scanner'
require 'sandi_meter/formatter'
module SandiMeter
  class Analyzer
    def analyze(source)
      @file_body = source
      @file_lines = @file_body.split(/$/).map { |l| l.gsub("\n", '') }
      @indentation_warnings = indentation_warnings

      sexp = Ripper.sexp(@file_body)
      scan_sexp(sexp)

      output
    end
  end
end

def sandi_it
  analyzer = SandiMeter::Analyzer.new
  data = analyzer.analyze params[:code]
  # Only long methods
  data[:methods].values.first.reject { |arr| arr[4] }.map { |arr| arr[0] }.join(', ')
rescue
  "Somethin' went wrong"
end
