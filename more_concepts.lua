ca = require('elca')
mu = require "musicutil"
engine.name = 'Passersby'
Passersby = include 'passersby/lib/passersby_engine'
help = include 'lib/helpers'
parameters = include 'lib/parameters'
get = include 'lib/gets'
set = include 'lib/sets'
fn = include 'lib/fn'
lattice = require("lattice")

function init()
    voice = {}
    stream = {}
    voice_lattice = lattice:new{}

    for i = 1,2 do
      voice[i] = {}
      voice[i].octave = 0
      voice[i].bit = 1
      voice[i].low = 1
      voice[i].high = 14
      voice[i].window = 8 -- shouldn't go larger than 32 (16?)
      voice[i].velocity = 100
      voice[i].rule = 30
      voice[i].seed = 36
      voice[i].stream = ca.new()
      voice[i].lattice = voice_lattice:new_pattern{
        action = function(t) 
          iterate(i)
        end,
        division = 1/16,
        enabled = true
      }
    end

    parameters.init()

    m = midi.connect(1)

    for i=1,2 do
        set.mode(voice[i].stream,"classic")
        set.rule(i,30)
        pass_seed(i,36)
    end

    names =  {}
    notes = {}
    for i = 1, #mu.SCALES do
        table.insert(names, string.lower(mu.SCALES[i].name))
        table.insert(notes, mu.generate_scale(0, names[i], 7))
    end

    note_pool = 1

    voice_lattice:start()
    screen_dirty = true
    go = clock.run(redraw_clock)
end

function redraw_clock()
  while true do
    clock.sleep(1/30)
    if screen_dirty then
      redraw()
      screen_dirty = false
    end
  end
end

function pass_seed(target,seed)
    voice[target].stream:clear()
    local binary_string = help.number_to_binary_string(seed)
    local incoming = {help.split(string.reverse(binary_string))}
    for i = 1,string.len(binary_string) do
        voice[target].stream.state[(voice[target].stream.NUM_STATES+1)-i] = tonumber(incoming[i])
    end
  end

function iterate(i)
        --print(get.current_seed(voice[i].stream:window(voice[i].window)), table.concat(voice[i].stream.state))
        if voice[i].stream.state[get.bit(i)] == 1 then
            local note = (48 + voice[i].octave * 12) + notes[note_pool][help.scale(get.low_note(i),get.high_note(i),math.abs(get.current_seed(voice[i].stream:window(get.window(i)))),voice[i])]
            if note ~= nil then
              if params:get("output_"..i) == 1 then
                engine.noteOn(i,help.midi_to_hz(note),voice[i].velocity)
              elseif params:get("output_"..i) == 2 then --JF
                -- todo
              elseif params:get("output_"..i) == 3 then --crow 1/2
                --todo
              elseif params:get("output_"..i) == 4 then --crow 3/4
                --todo
              elseif params:get("output_"..i) == 5 then --midi
                m:note_on(note,voice[i].velocity,params:get("midi_channel_voice_"..i))
                m:note_off(note,voice[i].velocity,params:get("midi_channel_voice_"..i))
              end
            end
        end
    voice[i].stream:update()
    screen_dirty = true
  end

  function redraw()
    screen.clear()
    screen.level(15)
    for i = 1,2 do
      for j = 1,voice[i].window+1 do
        if voice[i].stream.state[j] == 1 then
          screen.pixel((j*118/voice[i].window)-2,i == 1 and 0 or 45)
        end
        screen.pixel((voice[i].bit*118/voice[i].window)-2,i == 1 and 10 or 55)
      end
    end
    screen.fill()
    screen.update()
  end

  function enc(n,d)
    if n == 2 then
      params:delta("voice_1_bit",d) --make this stay below window size
    elseif n == 3 then
      params:delta("voice_2_bit",d)
    end
  end
