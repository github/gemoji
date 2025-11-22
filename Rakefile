require 'rake/testtask'

task :default => :test

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList["test/*_test.rb"]
end

namespace :db do
  desc %(Generate Emoji data files needed for development)
  task :generate => [
    'vendor/unicode-emoji-test.txt',
  ]

  desc %(Dump a list of supported Emoji with Unicode descriptions and aliases)
  task :dump => :generate do
    system 'ruby', '-Ilib', 'db/dump.rb'
  end
end

file 'vendor/unicode-emoji-test.txt' do |t|
  system 'curl', '-fsSL', 'http://unicode.org/Public/emoji/15.0/emoji-test.txt', '-o', t.name
end
---
title: 'Viewing the secret risk assessment report for your organization'
shortTitle: 'View risk report'
intro: 'Understand your organization''s exposure to leaked secrets at a glance by viewing your most recent {% data variables.product.prodname_secret_risk_assessment %} report.'
product: '{% data reusables.gated-features.secret-risk-assessment-report %}'
permissions: '{% data reusables.permissions.secret-risk-assessment-report-generation %}'
allowTitleToDifferFromFilename: true
type: how_to
versions:
  feature: secret-risk-assessment
topics:
  - Code Security
  - Secret scanning
  - Secret Protection
  - Organizations
  - Security
---

{% data reusables.organizations.navigate-to-org %}
{% data reusables.organizations.security-overview %}
{% data reusables.security-overview.open-assessments-view %} You can see the most recent report on this page.