// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "web/static/js/app.js".

// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/my_app/endpoint.ex":
import {Socket} from "phoenix"

let socket = new Socket("/socket", {params: {token: window.userToken}})

// When you connect, you'll often need to authenticate the client.
// For example, imagine you have an authentication plug, `MyAuth`,
// which authenticates the session and assigns a `:current_user`.
// If the current user exists you can assign the user's token in
// the connection for use in the layout.
//
// In your "web/router.ex":
//
//     pipeline :browser do
//       ...
//       plug MyAuth
//       plug :put_user_token
//     end
//
//     defp put_user_token(conn, _) do
//       if current_user = conn.assigns[:current_user] do
//         token = Phoenix.Token.sign(conn, "user socket", current_user.id)
//         assign(conn, :user_token, token)
//       else
//         conn
//       end
//     end
//
// Now you need to pass this token to JavaScript. You can do so
// inside a script tag in "web/templates/layout/app.html.eex":
//
//     <script>window.userToken = "<%= assigns[:user_token] %>";</script>
//
// You will need to verify the user token in the "connect/2" function
// in "web/channels/user_socket.ex":
//
//     def connect(%{"token" => token}, socket) do
//       # max_age: 1209600 is equivalent to two weeks in seconds
//       case Phoenix.Token.verify(socket, "user socket", token, max_age: 1209600) do
//         {:ok, user_id} ->
//           {:ok, assign(socket, :user, user_id)}
//         {:error, reason} ->
//           :error
//       end
//     end
//
// Finally, pass the token on connect as below. Or remove it
// from connect if you don't care about authentication.

socket.connect()

// Now that you are connected, you can join channels with a topic:
let channel = socket.channel("check", {})
channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })


channel.on("result", payload => {
  console.log("Received: [%s] %s", new Date(), payload.body)
})


var keyTimeout = 0;
var colours = ['#fff', '#ffefef', '#ffa4a4', '#ff9393', '#ff7272', '#ff6666'];
$(document).ready(function() {

    if(!$("#text")) {
        return;
    }
    // Note that the path doesn't matter right now; any WebSocket
    // connection gets bumped over to WebSocket consumers
    // var host = location.origin.replace(/^http/, 'ws')
    // socket = new WebSocket(host);
    // socket.onmessage = function(e) {
    //     console.log(e);

    //     var sentences = JSON.parse(e.data);
    //     var words = [];
    //     $('#text').highlightTextarea({
    //         words: words,
    //         id: 'text-wrap'
    //     });
    //     $('#text').data('highlighter').enable();
    //     $.each(sentences, function(i, sentence){
    //         // console.log(val + ": " + scores[i]);
    //         words.push({
    //             color: colours[Math.round(sentence.score * 5)],
    //             words: [sentence.sentence],
    //         })
    //     });
    //     $('#text').data('highlighter').setWords(words);
    //     console.log(words);
    //     $('#text').focus();
    // }
    $('#text').change(function(e) {
        if($('#text').val() == ""){
            return;
        }
        if(keyTimeout > 0){
            clearTimeout(keyTimeout);
        }
        keyTimeout = setTimeout(function() {
            channel.push("check", {body: $('#text').val()});
        }, 500);
    });


});  

export default socket
