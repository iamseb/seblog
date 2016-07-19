defmodule Seblog.Mailer do
  @config domain: Application.get_env(:seblog, :mailgun_domain),
          key: Application.get_env(:seblog, :mailgun_key),
          mode: Mix.env,
          test_file_path: "/tmp/mailgun.json"
  use Mailgun.Client, @config

  import Seblog.Router.Helpers
  alias Seblog.Post


  @from "seblog@sebpotter.com"
  @notify "seblog@sebpotter.com"

  def send_draft_notify(post) do

    url = post_url(Seblog.Endpoint, :quick_approve_draft, post.id, Post.sign_post_url(post))

    IO.inspect send_email to: @notify,
               from: @from,
               subject: "New draft: #{post.title}",
               html: Phoenix.View.render_to_string(Seblog.EmailView, "notify_draft_post.html", post: post, url: url)
  end
end