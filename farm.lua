--alpha 1

detector = "environment_detector_1"
D = peripheral.wrap(detector)

mob_of_interest = "pig"



function scan_mobs(mob,periph)
    local scan = periph.scanEntities(3)
    local output = {}
    local output["count"] = 0
    local output["baby"] = 0
    local output["inLove"] = 0
    for i=1, #scan do
        if scan[i].name == "mob" then
            output["count"] = output["count"] + 1
            if scan[i].isBaby == true then
                output["baby"] = output["baby"] + 1
            end
            if scan[i].inLove == true then
                output["inLove"] = output["inLove"] + 1
            end
        end
    end
    return output
end

while true do
    local mobs = scan_mobs(mob_of_interest,D)
    print("Found "..mobs["count"].." "..mob_of_interest.."s ("..mobs["baby"].." babies, "..mobs["inLove"].." in love)")
    os.sleep(5)
end

