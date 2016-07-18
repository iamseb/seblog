defmodule Seblog.Mailer do
  @config domain: Application.get_env(:seblog, :mailgun_domain),
          key: Application.get_env(:seblog, :mailgun_key),
          mode: Mix.env,
          test_file_path: "/tmp/mailgun.json"
  use Mailgun.Client, @config

  import Seblog.Router.Helpers

  @from "seblog@sebpotter.com"
  @notify "iamseb@gmail.com"

  def send_draft_notify(post) do

    url = page_url(Seblog.Endpoint, :show, post.pub_date.year, post.pub_date.month, post.slug)

    IO.inspect send_email to: @notify,
               from: @from,
               subject: "New draft: #{post.title}",
               text: "There's a new draft message. \n\n View it: #{url}"
  end
end