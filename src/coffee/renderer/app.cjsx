window.onload = () ->
  remote = require 'remote'
  React = require 'react'
  ReactDOM = require 'react-dom'
  request = require 'request'
  exec = require('child_process').exec
  fs = require 'fs'
  app = remote.require 'app'
  path = app.getPath('temp') + "com.txt"
  Comments = React.createClass
    render: () ->
      console.log @props.comments[0]
      if @props.newComments.length > 0 and @props.comments.length > 0
        n = document.getElementById "notification"
        n.play()
        str = @props.newComments.map((c)->c.message).join("\n")
        fs.writeFile(path, str, ->
          exec("SayKotoeri2 -f #{path}")
        )
      cb = (cl) ->
        (c) ->
          <li key={c.commentid} className="comment #{cl}">
            <img src={c.userstatus.image} />
            <div className="comment_body">
              <div className="comment_user_info">
                <div>{c.userid}</div>
                <div>{"(#{c.userstatus.name})"}</div>
              </div>
              <div>{c.message}</div>
            </div>
          </li>
      items = @props.newComments.map cb("new")
      items = items.concat @props.comments.map cb("")
      <ul className="comments">
        {items}
      </ul>

  Audios = React.createClass
    render: () ->
      return <div></div> if !@props.sound?
      return (
        <audio id="notification" src="./resource/audio/#{@props.sound}.wav" />
      )

  Contents = React.createClass
    getInitialState: () ->
      comments: []
      newComments: []
      latest: null
      sound: "pocopoco"
    componentDidMount: ->
      user = "seseri7th"
      user = "dannti3"
      req = =>
        url = "http://api.twitcasting.tv/api/commentlist?type=json&user=#{user}"
        url += "&since=#{@state.latest}" if @state.latest?
        request(url, (err, res) =>
          json = JSON.parse res.body
          state =
            comments: @state.newComments.concat @state.comments
            newComments: json
          state.latest = json[0].commentid if json.length > 0
          @setState state
        )
      req()
      # setTimeout req, 5000
      setInterval req, 5000
    render: () ->
      return (
        <div className="commentView">
        <Audios sound={@state.sound}/>
          <Comments comments={@state.comments}, newComments={@state.newComments}/>
        </div>
      )
  ReactDOM.render(
    <Contents />
    document.getElementById 'contents'
  )
