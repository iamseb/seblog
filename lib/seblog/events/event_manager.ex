defmodule Seblog.EventManager do

  @server __MODULE__

  def start_link do
    GenEvent.start_link [{:name, @server}]
  end

  # code omitted 

end  