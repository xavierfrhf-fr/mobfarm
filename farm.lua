--alpha 4


mob_of_interest = "Pig"


enclos_data = {
    [1] = {name = "Breeder",
        detector = "environment_detector_1",
        feeder = nil,
        adult = {
            objective = 10,
            min = 5,
            actual = 0
        },
        baby = {
            objective = 15,
            min = 7,
            actual = 0
        },
    },
    [2] = {name = "Grow-out",
        detector = "environment_detector_2",
        feeder = nil,
        adult = {
            objective = 0,
            min = 0,
            actual = 0
        },
        baby = {
            objective = 100,
            min = 0,
            actual = 0
        },
    },
    [3] = {name = "Sewer",
        detector = "environment_detector_3",
        feeder = nil,
        adult = {
            objective = 30,
            min = 15,
            actual = 0
        },
        baby = {
            objective = 0,
            min = 0,
            actual = 0
        }
    },
    [4] = {name = "Market",
        detector = "environment_detector_4",
        feeder = nil,
        adult = {
            objective = 50,
            min = 25,
            actual = 0
        },
        baby = {
            objective = 0,
            min = 0,
            actual = 0
        }
    }
}

mob_mover = {
    [1] = {
        
        redstone_relay = "redstone_relay_23",
        relay_side = "left",
        target_enclosure = 2,
        initial_enclosure = 1,
        baby_only = false
    },
    [2] = {
        redstone_relay = "redstone_relay_23",
        relay_side = "right",
        target_enclosure = 2,
        initial_enclosure = 1,
        baby_only = true
    },
    [3] = {
        redstone_relay = "redstone_relay_24",
        relay_side = "left",
        target_enclosure = 3,
        initial_enclosure = 2,
        baby_only = false
    },
    [4] = {
        redstone_relay = "redstone_relay_24",
        relay_side = "right",
        target_enclosure = 4,
        initial_enclosure = 2,
        baby_only = false
    },
    [5] = {
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
            if scan[i].baby == true then
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
        total[enclos_data[i].name] = scan
        enclos_data[i].adult.actual = scan.adult
        enclos_data[i].baby.actual = scan.baby
    end
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

function check_and_request_move()
    while true do
        scan_all_mobs()
        for enclos_ID, data in pairs(enclos_data) do
            if data.adult.actual < data.adult.objective then
                if enclos_ID == 1 then
                    -- Breeder can't request animals
                else
                    -- Request adult from previous enclosure
                    local previous_enclos = enclos_data[enclos_ID - 1]
                    if is_animal_available(previous_enclos.name, false) then
                        move_animal(enclos_ID)
                        break
                    end
                end
            if data.baby.actual < data.baby.objective then
                if enclos_ID == 1 then
                    -- Breeder can't request animals
                else
                    -- Request baby from previous enclosure
                    local previous_enclos = enclos_data[enclos_ID - 1]
                    if is_animal_available(previous_enclos.name, true) then
                        move_animal(enclos_ID)
                        break
                    end
                end
            end
        end
        coroutine.yield()
    end
end

function user_input_handler()
    while true do
        input = read()
        if input == "q" then
            os.shutdown()
        elif input == "manual" then
            print("Manual move requested. Enter initial enclosure ID:")
            local initial_ID = tonumber(read())
            print("Enter target enclosure ID:")
            local target_ID = tonumber(read())
            for i=1, #mob_mover do
                local mover = mob_mover[i]
                if mover.initial_enclosure == initial_ID and mover.target_enclosure == target_ID then
                    move_animal(target_ID)
                    print("Animal moved from enclosure "..initial_ID.." to enclosure "..target_ID)
                    break
                end
            end
        end
    end
end

function print_mob_summary()
    while true do
        scan_all_mobs()
        term.clear()
        term.setCursorPos(1,1)
        for enclosure, data in pairs(enclos_data) do
            print("Enclosure "..data.name..": Found "..data.adult.actual + data.baby.actual.." "..mob_of_interest.."s ("..data.baby.actual.." babies, "..data.adult.actual.." adults)")
        end
        os.sleep(10)
        coroutine.yield()
    end
end

parallel.waitForAll(print_mob_summary)


