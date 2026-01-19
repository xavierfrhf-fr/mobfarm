--alpha 3

detector = "environment_detector_1"
D = peripheral.wrap(detector)

mob_of_interest = "Pig"

mob_summary = {}

enclos_data = {
    1 = {name = "Breeder",
        detector = "environment_detector_1",
        feeder = nil,
        adult_upper = 10,
        adult_lower = 6
        },
    2 = {name = "Grow-out",
        detector = "environment_detector_2",
        feeder = nil,
        adult_upper = 20,
        adult_lower = 10
        },
    3 = {name = "Sewer",
        detector = "environment_detector_3",
        feeder = nil,
        adult_upper = 30,
        adult_lower = 15
        },
    4 = {name = "Market",
        detector = "environment_detector_4",
        feeder = nil,
        adult_upper = 50,
        adult_lower = 25
        }
}

mob_mover = {
    1 = {
        
        redstone_relay = "redstone_relay_23",
        relay_side = "left",
        target_enclosure = 2,
        initial_enclosure = 1,
        baby_only = false
    },
    2 = {
        redstone_relay = "redstone_relay_23",
        relay_side = "right",
        target_enclosure = 2,
        initial_enclosure = 1,
        baby_only = true
    },
    3 = {
        redstone_relay = "redstone_relay_24",
        relay_side = "left",
        target_enclosure = 3,
        initial_enclosure = 2,
        baby_only = false
    },
    4 = {
        redstone_relay = "redstone_relay_24",
        relay_side = "right",
        target_enclosure = 4,
        initial_enclosure = 2,
        baby_only = false
    },
    5 = {
        redstone_relay = "redstone_relay_25",
        relay_side = "left",
        target_enclosure = 4,
        initial_enclosure = 3,
        baby_only = false
    }
}

function scan_mobs(periph)
    local scan = periph.scanEntities(3)
    local output = { count = 0, baby = 0, adult = 0, inLove = 0 }
    for i=1, #scan do
        if scan[i].name == mob_of_interest then
            output.count = output.count + 1
            if scan[i].isBaby == true then
                output.baby = output.baby + 1
            else
                output.adult = output.adult + 1
            end
            if scan[i].inLove == true then
                output.inLove = output.inLove + 1
            end
        end
    end
    return output
end

function scan_all_mobs()
    local total = {}
    for i=1, #enclos_data do
        detector_periph = peripheral.wrap(enclos_data[i].detector)
        local scan = scan_mobs(detector_periph)
        total[enclos_data[i].enclos] = scan
    end
    mob_summary = total
    return total
end

function move_animal(target_enclos)
    for i=1, #mob_mover do
        local mover = mob_mover[i]
        if mover.target_enclosure == target_enclos then
            local relay = peripheral.wrap(mover.redstone_relay)
            relay.setOutput(mover.relay_side, true)
            os.sleep(0.5)
            relay.setOutput(mover.relay_side, false)
        end
    end
end

function is_animal_available(enclos, baby_only)
    local mobs = scan_all_mobs()
    local data = mobs[enclos]
    if baby_only == true then
        return data.baby > 0
    else
        return data.adult > 0
    end
end

function print_mob_summary()
    while true do
        scan_all_mobs()
        os.clear()
        for enclosure, data in pairs(mob_summary) do
            print("Enclosure "..enclosure..": Found "..data.count.." "..mob_of_interest.."s ("..data.baby.." babies, "..data.adult.." adults, "..data.inLove.." in love)")
        end
        os.sleep(10)
        coroutine.yield()
    end
end

parallel.waitForAll(print_mob_summary)


