module EACBaseMap

  def EAC_BASE_MAP
    {
      # AGENT PERSON
      "//eac-cpf//cpfDescription[child::identity/child::entityType='person']" => {
        :obj => :agent_person,
        :map => agent_person_base      
      },
      # AGENT CORPORATE ENTITY
      "//eac-cpf//cpfDescription[child::identity/child::entityType='corporateBody']" => {
        :obj => :agent_corporate_entity,
        :map => agent_corporate_entity_base
      },
      # AGENT FAMILY
      "//eac-cpf//cpfDescription[child::identity/child::entityType='family']" => {
        :obj => :agent_family,
        :map => agent_family_base
      }
    }
  end

  # agent person name attrs, followed by agent subrecs common to all types
  def agent_person_base
    {
      "//identity/nameEntry" => agent_person_name_map(:name_person, :names),
      "//identity/nameEntryParallel/nameEntry[1]" => agent_person_name_with_parallel_map(:name_person, :names),
      "//localDescriptions/localDescription[@localType='gender']" => agent_person_gender_map,
    }.merge(base_map_subfields)
  end

  # agent corporate name attrs, followed by agent subrecs common to all types
  def agent_corporate_entity_base
    {
      "//identity/nameEntry" => agent_corporate_entity_name_map(:name_corporate_entity, :names),
      "//identity/nameEntryParallel/nameEntry[1]" => agent_corporate_entity_name_with_parallel_map(:name_corporate_entity, :names),
    }.merge(base_map_subfields)
  end

  # agent family name attrs, followed by agent subrecs common to all types
  def agent_family_base
    {
      "//identity/nameEntry" => agent_family_name_map(:name_family, :names),
      "//identity/nameEntryParallel/nameEntry[1]" => agent_family_name_with_parallel_map(:name_family, :names),
    }.merge(base_map_subfields)
  end

  # These fields are common to all agent types and imported the same way
  def base_map_subfields 
    {
      "//eac-cpf//control/recordId" => agent_record_identifiers_map,
      "//eac-cpf//control/otherRecordId" => agent_other_record_identifiers_map,
      "//eac-cpf//control" => agent_record_control_map,
      "//eac-cpf/control/conventionDeclaration" => agent_conventions_declaration_map,
      "//eac-cpf/control/maintenanceHistory/maintenanceEvent" => agent_maintenance_history_map,
      "//eac-cpf/control/sources/source" => agent_sources_map,
      "//eac-cpf/cpfDescription/identity/entityId" => agent_identifier_map,
      "//eac-cpf/cpfDescription/description/existDates//date" => agent_date_single_map("existence", :dates_of_existence),
      "//eac-cpf/cpfDescription/description/existDates//dateRange" => agent_date_range_map("existence", :dates_of_existence),
      "//places/place" => agent_place_map,
      "//occupations/occupation" => agent_occupation_map,
      "//functions/function" => agent_function_map,
      "//localDescriptions/localDescription[@localType='associatedSubject']" => agent_topic_map,
      "//eac-cpf//biogHist" => agent_bioghist_note_map
    }
  end

  def agent_person_name_map(obj, rel)
    {
      :obj => obj,
      :rel => rel,
      :map => agent_person_name_components_map,
      :defaults => {
        :source => 'local',
        :rules => 'local',
        :primary_name => 'primary name',
        :name_order => 'direct',
      }
    }
  end

  def agent_person_name_with_parallel_map(obj, rel)
    {
      :obj => obj,
      :rel => rel,
      :map => agent_person_name_components_map.merge({
        "following-sibling::nameEntry" => agent_person_name_map(:parallel_name_person, :parallel_names),
      }),
      :defaults => {
        :source => 'local',
        :rules => 'local',
        :primary_name => 'primary name',
        :name_order => 'direct',
      }
    }
  end

  def agent_corporate_entity_name_map(obj, rel)
    {
      :obj => obj,
      :rel => rel,
      :map => agent_corporate_entity_name_components_map,
      :defaults => {
        :source => 'local',
        :rules => 'local',
        :primary_name => 'primary name',
        :name_order => 'direct',
      }
    }
  end

  def agent_corporate_entity_name_with_parallel_map(obj, rel)
    {
      :obj => obj,
      :rel => rel,
      :map => agent_corporate_entity_name_components_map.merge({
        "following-sibling::nameEntry" => agent_corporate_entity_name_map(:parallel_name_corporate_entity, :parallel_names),
      }),
      :defaults => {
        :source => 'local',
        :rules => 'local',
        :primary_name => 'primary name',
        :name_order => 'direct',
      }
    }
  end

  def agent_family_name_map(obj, rel)
    {
      :obj => obj,
      :rel => rel,
      :map => agent_family_name_components_map,
      :defaults => {
        :source => 'local',
        :rules => 'local',
        :primary_name => 'primary name',
        :name_order => 'direct',
      }
    }
  end

  def agent_family_name_with_parallel_map(obj, rel)
    {
      :obj => obj,
      :rel => rel,
      :map => agent_family_name_components_map.merge({
        "following-sibling::nameEntry" => agent_family_name_map(:parallel_name_family, :parallel_names),
      }),
      :defaults => {
        :source => 'local',
        :rules => 'local',
        :primary_name => 'primary name',
        :name_order => 'direct',
      }
    }
  end

  def agent_person_name_components_map
    {
       "self::nameEntry[@lang]" => Proc.new {|name, node|
         name[:language] = node.attr("lang")
       },
       "self::nameEntry[@scriptCode]" => Proc.new {|name, node|
         name[:script] = node.attr("scriptCode")
       },
       "descendant::part[@localType='prefix']" => Proc.new {|name, node|
         val = node.inner_text
         name[:prefix] = val
       },
       "descendant::part[@localType='suffix']" => Proc.new {|name, node|
         val = node.inner_text
         name[:suffix] = val
       },
       "descendant::part[@localType='title']" => Proc.new {|name, node|
         val = node.inner_text
         name[:title] = val
       },
       "descendant::part[@localType='surname']" => Proc.new {|name, node|
         val = node.inner_text
         name[:primary_name] = val
       },
       "descendant::part[@localType='forename']" => Proc.new {|name, node|
         val = node.inner_text
         name[:rest_of_name] = val
       },
       "descendant::part[@localType='numeration']" => Proc.new {|name, node|
         val = node.inner_text
         name[:number] = val
       },
       "descendant::part[@localType='fuller_form']" => Proc.new {|name, node  |
         val = node.inner_text
         name[:fuller_form] = val
       },
       "descendant::part[@localType='dates']" => Proc.new {|name, node|
         val = node.inner_text
         name[:dates] = val
       },
       "descendant::part[@localType='qualifier']" => Proc.new {|name, node|
         val = node.inner_text
         name[:qualifier] = val
       },
       "descendant::authorizedForm" => Proc.new {|name, node|
         val = node.inner_text
         name[:source] = val
         name[:authorized] = true
       },
       "descendant::alternativeForm" => Proc.new {|name, node|
         val = node.inner_text
         name[:source] = val
         name[:authorized] = false
       },
       "descendant::part[not(@localType)]" => Proc.new {|name, node|
         val = node.inner_text
         name[:primary_name] = val
         name[:dates] = val.scan(/[0-9]{4}-[0-9]{4}/).flatten[0]
       }, # if localType attr is not defined, assume primary_name
       "descendant::part[not(@localType='prefix') and   not(@localType='prefix') and not(@localType='suffix') and   not(@localType='title')  and not(@localType='surname')  and   not(@localType='forename') and not(@localType='numeration') and   not(@localType='fuller_form') and not(@localType='dates') and   not(@localType='qualifier')]" => Proc.new {|name, node|
         val = node.inner_text
         name[:primary_name] = val
         name[:dates] = val.scan(/[0-9]{4}-[0-9]{4}/).flatten[0]
       }, # if localType attr is something else
       "descendant::useDates//date" => agent_date_single_map("usage", :use_dates),
       "descendant::useDates//dateRange" => agent_date_range_map("usage", :use_dates)
     }
  end

  def agent_corporate_entity_name_components_map
    {
      "self::nameEntry[@lang]" => Proc.new {|name, node|
        name[:language] = node.attr("lang")
      },
      "self::nameEntry[@scriptCode]" => Proc.new {|name, node|
        name[:script] = node.attr("scriptCode")
      },
      "descendant::part[@localType='primary_name']" => Proc.new {|name, node|
        val = node.inner_text
        name[:primary_name] = val
      },
      "descendant::part[@localType='subordinate_name_1']" => Proc.new {|name, node|
        val = node.inner_text
        name[:subordinate_name_1] = val
      },
      "descendant::part[@localType='subordinate_name_2']" => Proc.new {|name, node|
        val = node.inner_text
        name[:subordinate_name_2] = val
      },
      "descendant::part[@localType='numeration']" => Proc.new {|name, node|
        val = node.inner_text
        name[:number] = val
      },
      "descendant::part[@localType='location']" => Proc.new {|name, node|
        val = node.inner_text
        name[:location] = val
      },
      "descendant::part[@localType='dates']" => Proc.new {|name, node|
        val = node.inner_text
        name[:dates] = val
      },
      "descendant::part[@localType='qualifier']" => Proc.new {|name, node|
        val = node.inner_text
        name[:qualifier] = val
      },
      "descendant::authorizedForm" => Proc.new {|name, node|
        val = node.inner_text
        name[:source] = val
        name[:authorized] = true
      },
      "descendant::alternativeForm" => Proc.new {|name, node|
        val = node.inner_text
        name[:source] = val
        name[:authorized] = false
      },
      "descendant::part[not(@localType)]" => Proc.new {|name, node|
        val = node.inner_text
        name[:primary_name] = val
        name[:dates] = val.scan(/[0-9]{4}-[0-9]{4}/).flatten[0]
      }, # if localType attr is not defined, assume primary_name
      "descendant::part[not(@localType='primary_name') and not(@localType='subordinate_name_1') and not(@localType='subordinate_name_2') and not(@localType='numeration') and not(@localType='location') and not(@localType='dates') and not(@localType='qualifier')]" => Proc.new {|name, node|
        val = node.inner_text
        name[:primary_name] = val
        name[:dates] = val.scan(/[0-9]{4}-[0-9]{4}/).flatten[0]
      }, # if localType attr is something else
      "descendant::useDates//date" => agent_date_single_map("usage", :use_dates),
      "descendant::useDates//dateRange" => agent_date_range_map("usage", :use_dates),
    }
  end

  def agent_family_name_components_map
    {
      "self::nameEntry[@lang]" => Proc.new {|name, node|
        name[:language] = node.attr("lang")
      },
      "self::nameEntry[@scriptCode]" => Proc.new {|name, node|
        name[:script] = node.attr("scriptCode")
      },
      "descendant::part[@localType='prefix']" => Proc.new {|name, node|
        val = node.inner_text
        name[:prefix] = val
      },
      "descendant::part[@localType='surname']" => Proc.new {|name, node|
        val = node.inner_text
        name[:family_name] = val
      },
      "descendant::part[@localType='family_type']" => Proc.new {|name, node|
        val = node.inner_text
        name[:family_type] = val
      },
      "descendant::part[@localType='location']" => Proc.new {|name, node|
        val = node.inner_text
        name[:location] = val
      },
      "descendant::part[@localType='dates']" => Proc.new {|name, node|
        val = node.inner_text
        name[:dates] = val
      },
      "descendant::part[@localType='qualifier']" => Proc.new {|name, node|
        val = node.inner_text
        name[:qualifier] = val
      },
      "descendant::authorizedForm" => Proc.new {|name, node|
        val = node.inner_text
        name[:source] = val
        name[:authorized] = true
      },
      "descendant::alternativeForm" => Proc.new {|name, node|
        val = node.inner_text
        name[:source] = val
        name[:authorized] = false
      },
      "descendant::part[not(@localType)]" => Proc.new {|name, node|
        val = node.inner_text
        name[:family_name] = val
        name[:dates] = val.scan(/[0-9]{4}-[0-9]{4}/).flatten[0]
      }, # if localType attr is not defined, assume primary_name
      "descendant::part[not(@localType='prefix') and not(@localType='surname') and not(@localType='family_type') and not(@localType='location') and not(@localType='dates') and not(@localType='qualifier')]" => Proc.new {|name, node|
        val = node.inner_text
        name[:family_name] = val
        name[:dates] = val.scan(/[0-9]{4}-[0-9]{4}/).flatten[0]
      }, # if localType attr is something else, assume primary_name
      "descendant::useDates//date" => agent_date_single_map("usage", :use_dates),
      "descendant::useDates//dateRange" => agent_date_range_map("usage", :use_dates)
    }
  end


  def agent_record_identifiers_map
    {
      :obj => :agent_record_identifier,
      :rel => :agent_record_identifiers,
      :map => {
        "self::recordId" => Proc.new {|id, node|
          val = node.inner_text
          id[:record_identifier] = val
          id[:primary_identifier] = true
        }
      },
      :defaults => {
        :primary_identifier => true,
        :source_enum => "local" 
      }
    }
  end  

  def agent_other_record_identifiers_map
    {
      :obj => :agent_record_identifier,
      :rel => :agent_record_identifiers,
      :map => {
         "self::otherRecordId" => Proc.new {|id, node|
          val = node.inner_text
          id[:record_identifier] = val
          id[:primary_identifier] = false
          id[:identifier_type_enum] = node.attr("localType")
        },
      },
      :defaults => {
        :primary_identifier => false,
        :source_enum => "local" 
      }
    }
  end

  def agent_record_control_map
    {
      :obj => :agent_record_control,
      :rel => :agent_record_controls,
      :map => {
        "descendant::maintenanceStatus" => Proc.new {|arc, node|
          val = node.inner_text
          arc[:maintenance_status_enum] = val
        },
        "descendant::maintenanceAgency/agencyCode" => Proc.new {|arc, node|
          val = node.inner_text
          arc[:maintenance_agency] = val
        },
        "descendant::maintenanceAgency/agencyName" => Proc.new {|arc, node|
          val = node.inner_text
          arc[:agency_name] = val
        },
        "descendant::maintenanceAgency/descriptiveNote" => Proc.new {|arc, node|
          val = node.inner_text
          arc[:maintenance_agency_note] = val
        },
        "descendant::publicationStatus" => Proc.new {|arc, node|
          val = node.inner_text
          arc[:publication_status_enum] = val
        },
        "descendant::languageDeclaration/language" => Proc.new {|arc, node|
          arc[:language] = node.attr("languageCode")
          arc[:script] = node.attr("scriptCode")
        },
        "descendant::languageDeclaration/descriptiveNote" => Proc.new {|arc, node|
          val = node.inner_text
          arc[:language_note] = val
        }
      },
      :defaults => {
        :maintenance_status_enum => "new"
      }
    }
  end

  def agent_conventions_declaration_map
    {
      :obj => :agent_conventions_declaration,
      :rel => :agent_conventions_declarations,
      :map => {
        "descendant::abbreviation" => Proc.new {|dec, node|
          val = node.inner_text.downcase
          dec[:name_rule] =  val
        },
        "descendant::citation" => Proc.new {|dec, node|
          val = node.inner_text
          dec[:citation] = (val.nil? || val.length == 0) ? "citation" : val
          dec[:file_uri] = node.attr("href")
          dec[:file_version_xlink_actuate_attribute] = node.attr("actuate")
          dec[:file_version_xlink_show_attribute] = node.attr("show")
          dec[:xlink_title_attribute] = node.attr("title")
          dec[:xlink_role_attribute] = node.attr("role")
          dec[:last_verified_date] = node.attr("lastDateTimeVerified")
        },
        "descendant::descriptiveNote" => Proc.new {|dec, node|
          val = node.inner_text
          dec[:descriptive_note] = val
        },
      },
      :defaults => {
        :citation => "citation",
        :name_rule => "local"
      }
    }
  end

  def agent_maintenance_history_map
    {
      :obj => :agent_maintenance_history,
      :rel => :agent_maintenance_histories,
      :map => {
        "descendant::eventType" => Proc.new {|me, node|
          val = node.inner_text.downcase
          me[:maintenance_event_type_enum] =  val
        },
        "descendant::agentType" => Proc.new {|me, node|
          val = node.inner_text
          me[:maintenance_agent_type_enum] =  val
        },
        "descendant::agent" => Proc.new {|me, node|
          val = node.inner_text
          me[:agent] =  val
        },
        "descendant::eventDateTime" => Proc.new {|me, node|
          val = node.attr("standardDateTime")
          val2 = node.inner_text

          me[:event_date] =  val
          me[:event_date] = val2 if val.nil?
        },
        "descendant::eventDescription" => Proc.new {|me, node|
          val = node.inner_text
          me[:descriptive_note] =  val
        },
      },
      :defaults => {
      }
    }
  end

  def agent_sources_map
    {
      :obj => :agent_sources,
      :rel => :agent_sources,
      :map => {
        "self::source" => Proc.new {|s, node|
          s[:file_uri] = node.attr("href")
          s[:file_version_xlink_actuate_attribute] = node.attr("actuate")
          s[:file_version_xlink_show_attribute] = node.attr("show")
          s[:xlink_title_attribute] = node.attr("title")
          s[:xlink_role_attribute] = node.attr("role")
          s[:last_verified_date] = node.attr("lastDateTimeVerified")
        },
        "descendant::sourceEntry" => Proc.new {|s, node|
          val = node.inner_text
          s[:source_entry] = val
        },
        "descendant::descriptiveNote" => Proc.new {|s, node|
          val = node.inner_text
          s[:descriptive_note] = val
        },
      },
      :defaults => {
      }
    }
  end

  def agent_identifier_map
    {
      :obj => :agent_identifier,
      :rel => :agent_identifiers,
      :map => {
        "self::entityId" => Proc.new {|id, node|
          val = node.inner_text
          id[:entity_identifier] = val
          id[:identifier_type_enum] = node.attr("localType")
        }
      },
      :defaults => {
      }
    }
  end

  def agent_date_single_map(label = nil, rel = :dates)
    {
      :obj => :structured_date_label,
      :rel => rel,
      :map => {
        "self::date" => Proc.new {|date, node|
          exp = node.inner_text
          role = "begin"
          type = "single"

          label = node.attr("localType") if label.nil?
          label = "other" if label.nil?

          if node.attr("standardDate")
            std = node.attr("standardDate")

            if node.attr("notBefore")
              std_type = node.attr("notBefore")
            elsif node.attr("notAfter")
              std_type = node.attr("notAfter")
            else
              std_type = nil
            end
          else
            std = nil
            std_type = nil
          end

          sds = ASpaceImport::JSONModel(:structured_date_single).new({
            :date_role_enum => role,
            :date_expression => exp,
            :date_standardized => std,
            :date_standardized_type_enum => std_type
          })

          date[:date_label] = label
          date[:date_type_enum] = type
          date[:structured_date_single] = sds
        }
      },
      :defaults => {
      }
    }
  end

  def agent_date_range_map(label = nil, rel = :dates)
    {
      :obj => :structured_date_label,
      :rel => rel,
      :map => {
        "self::dateRange" => Proc.new {|date, node|
          label = node.attr("localType") if label.nil?
          label = "other" if label.nil?


          type = "range"

          begin_node = node.search("//fromDate")
          end_node = node.search("//toDate")

          begin_exp = begin_node.inner_text
          end_exp = end_node.inner_text

          begin_std = begin_node.attr("standardDate") ? begin_node.attr("standardDate").value : nil
          end_std = end_node.attr("standardDate") ? end_node.attr("standardDate").value : nil

          if begin_std
            if begin_node.attr("notBefore")
              begin_std_type = begin_node.attr("notBefore").value
            elsif begin_node.attr("notAfter")
              begin_std_type = begin_node.attr("notAfter").value
            else
              begin_std_type = nil
            end
          else
            begin_std_type = nil
          end

          if end_std
            if end_node.attr("notBefore")
              end_std_type = end_node.attr("notBefore").value
            elsif end_node.attr("notAfter")
              end_std_type = end_node.attr("notAfter").value
            else
              end_std_type = nil
            end
          else
            end_std_type = nil
          end

          sdr = ASpaceImport::JSONModel(:structured_date_range).new({
            :begin_date_expression => begin_exp,
            :begin_date_standardized => begin_std,
            :begin_date_standardized_type_enum => begin_std_type,
            :end_date_expression => end_exp,
            :end_date_standardized => end_std,
            :end_date_standardized_type_enum => end_std_type
          })

          date[:date_label] = label
          date[:date_type_enum] = type
          date[:structured_date_range] = sdr
        }
      },
      :defaults => {
      }
    }
  end

  def agent_person_gender_map
    {
      :obj => :agent_gender,
      :rel => :agent_genders,
      :map => {
        "descendant::term" => Proc.new {|gender, node|
          val = node.inner_text
          gender[:gender_enum] = val
        },
        "descendant::date" => agent_date_single_map,
        "descendant::dateRange" => agent_date_range_map,
        "descendant::descriptiveNote" => agent_text_note_map("self::descriptiveNote"),
      },
      :defaults => {
      }
    }
  end  


  def agent_place_map
    {
    :obj => :agent_place,
    :rel => :agent_places,
    :map => {
      "descendant::placeRole" => Proc.new {|apl, node|
        val = node.inner_text
        apl[:place_role_enum] = val
      },

      "descendant::placeEntry" => subject_map("self::placeEntry",
                                              subject_terms_map("geographic"), 
                                              subject_source_map),

      "descendant::date" => agent_date_single_map,

      "descendant::dateRange" => agent_date_range_map,

      "descendant::descriptiveNote" => agent_text_note_map("self::descriptiveNote"),

      "descendant::citation" => agent_citation_note_map("self::citation")
      },
    }
  end

  def agent_occupation_map
    {
    :obj => :agent_occupation,
    :rel => :agent_occupations,
    :map => {
   
      "descendant::term" => subject_map("self::term",
                                         subject_terms_map("occupation"), 
                                         subject_source_map),

      "descendant::date" => agent_date_single_map,

      "descendant::dateRange" => agent_date_range_map,

      "descendant::descriptiveNote" => agent_text_note_map("self::descriptiveNote"),

      "descendant::citation" => agent_citation_note_map("self::citation")
      },
    }
  end

  def agent_function_map
    {
    :obj => :agent_function,
    :rel => :agent_functions,
    :map => {
   
      "descendant::term" => subject_map("self::term",
                                         subject_terms_map("function"), 
                                         subject_source_map),

      "descendant::date" => agent_date_single_map,

      "descendant::dateRange" => agent_date_range_map,

      "descendant::descriptiveNote" => agent_text_note_map("self::descriptiveNote"),

      "descendant::citation" => agent_citation_note_map("self::citation")
      },
    }
  end

  def agent_topic_map
    {
    :obj => :agent_topic,
    :rel => :agent_topics,
    :map => {
   
      "descendant::term" => subject_map("self::term",
                                         subject_terms_map("topical"), 
                                         subject_source_map),

      "descendant::date" => agent_date_single_map,

      "descendant::dateRange" => agent_date_range_map,

      "descendant::descriptiveNote" => agent_text_note_map("self::descriptiveNote"),

      "descendant::citation" => agent_citation_note_map("self::citation")
      },
    }
  end

  def agent_bioghist_note_map
    {
      :obj => :note_bioghist,
      :rel => :notes,
      :map => {
        "self::biogHist" => Proc.new {|note, node|
          note['subnotes'] << {
            'jsonmodel_type' => 'note_text',
            'content' => node.inner_text
          }
        }
      },
      :defaults => {
        :label => 'default label'
      }
    }
  end

  def agent_text_note_map(xpath)
    {
      :obj => :note_text,
      :rel => :notes,
      :map => {
        xpath => Proc.new {|note, node|
          note.content = node.inner_text
        }
      },
      :defaults => {
      }
    }
  end

  def agent_citation_note_map(xpath)
    {
      :obj => :note_citation,
      :rel => :notes,
      :map => {
        xpath => Proc.new {|note, node|
          note.content << node.inner_text
        }
      },
      :defaults => {
      }
    }
  end

  def subject_terms_map(term_type)
    Proc.new {|node|
      [{:term_type => term_type, 
       :term => node.inner_text, 
       :vocabulary => '/vocabularies/1'}]
    }
  end

  def subject_source_map
    Proc.new {|node|
      source = node.attr("vocabularySource") 
    }
  end

  # usually, rel will be :subjects, but in some cases it will be :places
  def subject_map(xpath, terms, source, rel = :subjects)
    {
      :obj => :subject,
      :rel => rel,
      :map => {
        xpath => Proc.new{|subject, node|
          subject.publish = true
          subject.authority_id = node.attr("vocabularySource")
          subject.terms = terms.call(node)
          subject.source = source.call(node)
          subject.vocabulary = '/vocabularies/1'
        }
      },
      :defaults => {
        :source => "Source not specified"
      }
    }
  end
end
