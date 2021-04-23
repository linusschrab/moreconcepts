local set = {}

function set.mode(target,m)
  if m == "classic" then
    target.bound_mode_l = 2
    target.bound_mode_r = 2
    target.bound_l = 1
    target.bound_r = 8
    target.NUM_STATES = 8
  end
end

function set.state(target,index,s)
  target.state[index] = s
end

function set.rule(target,r)
  voice[target].stream.rule = r
  pass_seed(target,params:get("voice_"..target.."_seed"))
end

function set.seed(target,r)
  pass_seed(target,params:get("voice_"..target.."_seed"))
end

function set.bit(voice_id,position)
  voice[voice_id].bit = position
end

function set.low_note(voice_id,note)
  voice[voice_id].low = util.clamp(1,29,note)
end

function set.high_note(voice_id,note)
  voice[voice_id].high = util.clamp(1,29,note)
end

function set.octave(voice_id,oct)
  voice[voice_id].octave = util.clamp(-3,3,oct)
end

function set.window(voice_id,width)
  voice[voice_id].window = util.clamp(1,32,width)
end

function set.velocity(voice_id,vel)
  voice[voice_id].velocity = vel
end

function set.midichannel(voice_id,ch)
  voice[voice_id].midichannel = ch
end

function set.mididevice(voice_id,d)
  voice[voice_id].mididevice = d
  voice[voice_id].midi = midi.connect(d)
end

function set.time(voice_id,t)
  voice[voice_id].lattice.division = 1/t
end

return set