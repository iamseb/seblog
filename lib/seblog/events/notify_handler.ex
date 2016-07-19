defmodule Seblog.NotifyHandler do

    use GenEvent

    def handle_event({:notify_content, post}, messages) do
        # IO.puts "Called content notify with: "
        # IO.inspect post
        post = post
        |> email_notify
        |> slack_notify
        {:ok, [post|messages]}
    end

    def email_notify(post) do
        post = case post do
            %Seblog.Post{:status => "draft"} ->
                # IO.puts "Got draft status, mailing"
                post |> Seblog.Mailer.send_draft_notify 
                post
            _ -> post
        end
        post
    end

    def slack_notify(post) do
        post
    end

end