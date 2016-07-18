defmodule Seblog.Mailer do
  @config domain: Application.get_env(:seblog, :mailgun_domain),
          key: Application.get_env(:seblog, :mailgun_key),
          mode: :test,
          test_file_path: "/tmp/mailgun.json"
  use Mailgun.Client, @config

  import Seblog.Router.Helpers

  @from "seblog@sebpotter.com"
  @notify "iamseb@gmail.com"

  def send_draft_notify(post) do

    url = page_url(Seblog.Endpoint, :show, post.pub_date.year, post.pub_date.month, post.slug)

    send_email to: @notify,
               from: @from,
               subject: "New draft: #{post.title}",
               html: "There's a new draft message. \n\n View it: <a href=\"#{url}\"></a>"
  end
end