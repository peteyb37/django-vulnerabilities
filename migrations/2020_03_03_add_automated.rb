require 'yaml'

# MIGRATION STATUS: Done.
raise 'Migration already performed.' # Don't run this. Kept for posterity

def order_of_keys
  %w(
    CVE
    yaml_instructions
    curated_instructions
    curated
    reported_instructions
    reported_date
    announced_instructions
    announced_date
    published_instructions
    published_date
    description_instructions
    description
    bounty_instructions
    bounty
    reviews
    bugs
    repo
    fixes_vcc_instructions
    fixes
    vccs
    upvotes_instructions
    upvotes
    unit_tested
    discovered
    discoverable
    specification
    subsystem
    interesting_commits
    i18n
    sandbox
    ipc
    lessons
    mistakes
    CWE_instructions
    CWE
    CWE_note
    nickname_instructions
    nickname
  )
end

def updated_yaml_instructions
  <<~EOS
===YAML Primer===
This is a dictionary data structure, akin to JSON.
Everything before a colon is a key, and the values here are usually strings
For one-line strings, you can just use quotes after the colon
For multi-line strings, as we do for our instructions, you put a | and then
indent by two spaces

For readability, we hard-wrap multi-line strings at 80 characters. This is
not absolutely required, but appreciated.
  EOS
end

def discoverable_question
  instructions = <<~EOS
Is it plausible that a fully automated tool could have discovered
this? These are tools that require little knowledge of the domain,
 e.g. automatic static analysis, compiler warnings, fuzzers.

Examples for true answers: SQL injection, XSS, buffer overflow

Examples for false: RFC violations, permissions issues, anything
that requires the tool to be "aware" of the project's
domain-specific requirements.

The answer field should be boolean. In answer_note, please explain
why you come to that conclusion.
  EOS
  return {
    'instructions' => instructions,
    'answer_note' => nil,
    'answer' => nil
  }
end

def spec_question
  specification_instructions = <<~EOS
Is there mention of a violation of a specification? For example,
an RFC specification, a protocol specification, or a requirements
specification.

Be sure to check all artifacts for this: bug report, security
advisory, commit message, etc.

The answer field should be boolean. In answer_note, please explain
why you come to that conclusion.
  EOS
  return {
    'instructions' => specification_instructions,
    'answer_note' => nil,
    'answer' => nil
  }
end

def cwe_inst
  <<~EOS
Please go to http://cwe.mitre.org and find the most specific, appropriate CWE
entry that describes your vulnerability. We recommend going to
https://cwe.mitre.org/data/definitions/699.html for the Software Development
view of the vulnerabilities. We also recommend the tool
http://www.cwevis.org/viz to help see how the classifications work.

If you have anything to note about why you classified it this way, write
something in CWE_note. This field is optional.

Just the number here is fine. No need for name or CWE prefix. If more than one
apply here, then choose the best one and mention the others in CWE_note.
  EOS
end

def i18n_question
  <<~EOS
  Was the feature impacted by this vulnerability about internationalization
  (i18n)? An internationalization feature is one that enables people from all
  over the world to use the system. This includes translations, locales,
  typography, unicode, or various other features.

  Answer should be boolean. Write a note about how you came to the conclusions
  you did.
  EOS
end



ymls = Dir['cves/*.yml'] + ['skeletons/cve.yml']
ymls.each do |yml_file|
    h = YAML.load(File.open(yml_file, 'r').read)
    h['yaml_instructions'] = updated_yaml_instructions
    h['discoverable'] = discoverable_question
    h['specification'] = spec_question
    h['CWE_instructions'] = cwe_inst
    h['i18n']['question'] = i18n_question
    # Reconstruct the hash in the order we specify
    out_h = {}
    order_of_keys.each do |key|
      out_h[key] = h[key]
    end

    # Generate the new YML, clean it up, write it out.
    File.open(yml_file, "w+") do |file|
      yml_txt = out_h.to_yaml[4..-1] # strip off ---\n
      stripped_yml = ""
      yml_txt.each_line do |line|
        stripped_yml += "#{line.rstrip}\n" # strip trailing whitespace
      end
      file.write(stripped_yml)
      print '.'
    end
end
puts 'Done!'
