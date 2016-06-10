class @ShowYourTerms
  constructor: (@container, @replay = true) ->
    @container = document.querySelector(@container)
    @outputIndex = 0
    @content = []
    if @container.innerText.length > 0
      @declarativeBuilder()

  declarativeBuilder: ->
    for element in @container.children
      switch element.getAttribute('data-action')
        when "command"
          @addCommand element.innerText, {styles: element.classList, delay: element.getAttribute('data-delay')}
        when "line"
          @addLine element.innerText, {styles: element.classList, delay: element.getAttribute('data-delay')}
    @container.style.height = window.getComputedStyle(@container, null).getPropertyValue("height")
    @container.innerHTML = ''

  addCommand: (content, options = {}) ->
    @content.push ["command", content, options]
    return self

  addLine: (content, options = {}) ->
    @content.push ["line", content, options]

  start: ->
    @outputGenerator(@content[@outputIndex])

  callNextOutput: (delay = 800) ->
    @outputIndex = @outputIndex + 1
    if @content[@outputIndex]
      waitForIt delay, => @outputGenerator(@content[@outputIndex])
    else
      if @replay
        @outputIndex = -1
        waitForIt delay, =>
          @callNextOutput()
          @container.innerHTML = ''

  outputGenerator: (output) ->
    type = output[0]
    content = output[1]
    options = output[2]

    currentLine = document.createElement("div")

    if options.styles
      currentLine.setAttribute("class", options.styles)

    if options.speed
      speed = options.speed
    else
      speed = 100

    currentLine.className += " active"

    switch type
      when "command"
        characters = content.split('')

        counter = 0
        interval = setInterval(( =>
          text = document.createTextNode(characters[counter])
          currentLine.appendChild(text)
          @container.appendChild(currentLine)

          counter++

          if counter == characters.length
            @removeClass(currentLine, 'active')
            @callNextOutput(options.delay)
            clearInterval interval
        ), speed)

      when "line"
        text = document.createTextNode(content)
        currentLine.appendChild(text)
        @container.appendChild(currentLine)

        @removeClass(currentLine, 'active')
        @callNextOutput(options.delay)

  removeClass: (el, classname) ->
    el.className = el.className.replace(classname,'')

# Helpers
waitForIt = (ms, func) => setTimeout func, ms
