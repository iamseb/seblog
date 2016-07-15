defmodule Seblog.Cloudflare do
  @api_user Application.get_env(:seblog, Seblog.Endpoint)[:cloudflare_api_user]
  @api_key Application.get_env(:seblog, Seblog.Endpoint)[:cloudflare_api_key]

  def purge_cache(files) do
    case Mix.env do
      :prod -> 
        
        cf_headers = %{"X-Auth-Email" => @api_user, "X-Auth-Key" => @api_key, "Content-Type" => "application/json"}
        case HTTPoison.get("https://api.cloudflare.com/client/v4/zones?name=sebpotter.com&status=active", cf_headers, [follow_redirect: true]) do
          {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
            body
            |> Poison.Parser.parse!
            |> Map.get("result")
            |> Enum.each(fn(x) -> call_cache_url(Map.get(x, "id"), files) end)
            :ok
          _ ->
            :error
        end
      _ ->
        :ok
    end
  end

  defp call_cache_url(zone_id, files) do
    cf_headers = %{"X-Auth-Email" => @api_user, "X-Auth-Key" => @api_key, "Content-Type" => "application/json"}
    data = %{files: files} |> Poison.encode!
    IO.inspect HTTPoison.request(
      :delete,
      "https://api.cloudflare.com/client/v4/zones/#{zone_id}/purge_cache", 
      data, 
      cf_headers
    )
  end    
    
end