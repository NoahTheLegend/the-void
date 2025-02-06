namespace Status
{
    enum statuses
    {
        energy = 0,
        oxygen
    };
}

const StatusEffect@[] status_collection = {
    @StatusEnergy("Energy", "Your energy.\nAllows you to move in space.", "EnergyStat.png"),
    @StatusEffect("Oxygen", "Your oxygen.\nSuffocation is a common thing out there.", "OxygenStat.png")
};

StatusEffect getStatus(u8 id)
{
    StatusEffect status = status_collection[id];
    return status;
}

StatusEffect makeStatus(string name, string description = "", string icon = "", Vec2f size = Vec2f(32,32))
{
    return StatusEffect(name, description, icon, size);
}

class StatusEffect {
    string name;
    string description;

    string icon;
    Vec2f size;
    u8 frame;
    f32 scale;

    u8 id;
    u8 gap;
    

    StatusEffect(string _name, string _description, string _icon, Vec2f _size = Vec2f(32,32))
    {
        name = _name;
        icon = _icon;
        size = _size;
        frame = 0;
        scale = 1;
        description = _description;

        id = 0;
        gap = 8;
    }

};

class StatusEnergy : StatusEffect {
    StatusEnergy(string _name, string _description, string _icon, Vec2f _size = Vec2f(16,16))
    {
        super(_name, _description, _icon, _size);
        
        this.id = Status::energy;
    }
};