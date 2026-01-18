--alpha 1

detector = "environment_detector_1"
D = peripheral.wrap(detector)

mob_of_interest = "Pig"

periphs_ids = {
    1 = {name = "environment_detector_1",
           enclos = 1,
           periph = nil},
}

enclos_data = {
    1 = {name = "Breeder",
          feeder = nil}
}

mob_mover = {
    1 = {
        
        redstone_relay = "redstone_relay_1",
        relay_side = "left",
        target_enclosure = 2,
        initial_enclosure = 1,
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
    for i=1, #periphs_ids do
        if periphs_ids[i].periph == nil then
            periphs_ids[i].periph = peripheral.wrap(periphs_ids[i].name)
        end
        local scan = scan_mobs(periphs_ids[i].periph)
        total[periphs_ids[i].enclos] = scan
    end
    return total
end

while true do
    local mobs = scan_all_mobs()
    for enclosure, data in pairs(mobs) do
        print("Enclosure "..enclosure..": Found "..data.count.." "..mob_of_interest.."s ("..data.baby.." babies, "..data.adult.." adults, "..data.inLove.." in love)")
    end
    os.sleep(5)
end

