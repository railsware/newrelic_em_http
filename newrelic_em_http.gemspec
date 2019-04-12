# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "newrelic_em_http"
  spec.version       = "0.0.4"
  spec.authors       = ["Andriy Yanko"]
  spec.email         = ["andriy.yanko@railsware.com"]

  spec.summary       = %q{EM::HTTP instrumentation for New Relic RPM}
  spec.homepage      = "https://github.com/railsware/newrelic_em_http"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "newrelic_rpm", "> 6.0.0"

  spec.add_development_dependency "eventmachine", ">= 1.2.0"
  spec.add_development_dependency "em-http-request", ">= 1.0.0"

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
