require "serverspec"
require_relative "nginx"

shared_examples "curl request cache" do |expires|
  it "has an ETag" do
    expect(subject.stdout.gsub(/\r/, '')).to match /^ETag: "[[:xdigit:]-]+"$/
  end

  # If expires isn't a number of days, assume we used "epoch" and there's no max-age to check
  if expires.is_a? Integer
    it "includes cache control max age" do
      expect(subject.stdout.gsub(/\r/, '')).to match /^Cache-Control: max-age=#{Regexp.quote((expires * 24 * 3600).to_s)}/
    end
  end

  it "includes expires date" do
    if expires.is_a? Integer
      expires = DateTime.httpdate(subject.stdout.gsub(/\r/, '').match(/^Date: (.+)$/)[1]) + expires
    end

    expect(subject.stdout.gsub(/\r/, '')).to match /^Expires: #{Regexp.quote(expires.httpdate)}$/
  end
end
