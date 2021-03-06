class Jira

  MRM_PROJECT_ID="10001"
  #MRM_PROJECT_ID="11000"

  attr_accessor :user
  attr_accessor :message
  attr_accessor :environment
  attr_accessor :title
  attr_accessor :labels
  attr_accessor :doc_ref
  attr_accessor :dev_ref

  def initialize(user: nil, message: nil, environment: {}, title: "Une erreur est survenue", labels: [], doc_ref: nil, dev_ref: nil)
    self.user=user
    self.message=message
    self.environment = environment
    self.title = title
    self.labels = labels
    self.doc_ref= doc_ref
    self.dev_ref= dev_ref
  end

  def default_labels
    []
  end

  def user_environment
    {
        "|Infos User|"=>"| |",
        "UUID" => "[#{@user.uuid}|#{link_for_uuid(@user.uuid)}]",
        "HRUID" => @user.hruid,
        "Prénom" => @user.firstname,
        "Nom" => @user.lastname,
    }
  end

  def footer
    footer="\nh3. Instructions à destination de l'équipe support\n"
    footer+= "Documentation de diagnostique et de résolution du problème : #{self.doc_ref}\n"  if self.doc_ref
    footer+= "Développeur référent:  #{self.dev_ref}\n"  if self.dev_ref
    footer+="Application :  #{Rails.application.secrets.app_name}\n"
    footer+=format_for_table(user_environment)+"\n" if self.user
    footer+="Informations sur l'erreur :\n #{format_for_table(self.environment)}\n" if self.environment.to_h.any?
    footer
  end


  def labels
    (@labels+default_labels).uniq
  end

  def send
    JiraIssue.create(
        fields: {
            project: { id: MRM_PROJECT_ID },
            summary: title,
            description: message+"\n"+footer,
            customfield_10000: @user.try(:email) ,
            issuetype: { id: "1" },
            labels: labels
        })
  end

  private

    def link_for_uuid(uuid)
      "https://moncompte.gadz.org/admin/info_user?uuid=#{user.uuid}"
    end

    def format_for_table(value,escape_hash:false)
      klass=value.class
      case
        when klass <= Hash
          if escape_hash
            "{panel:borderStyle=none}"+value.map{|k,v| "|#{k}|#{format_for_table(v)}|"}.join("\n")+"{panel}"
          else
            value.map{|k,v| "|#{k}|#{format_for_table(v,escape_hash:true)}|"}.join("\n")
          end
      when klass <= Array
        "{panel:borderStyle=none}"+value.map{|v| "|#{format_for_table(v,escape_hash:true)}|"}.join("\n")+"{panel}"
      else
        value.to_s
      end
    end

end