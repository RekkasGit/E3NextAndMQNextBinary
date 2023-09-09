local library = {}

library['Properties'] = {
    {
        ["Inverse"] = false;
        ["DependsOnValue"] = "war,shd,clr,shm,mag,bst,mnk,ber,rog,enc";
        ["Type"] = "Observed";
        ["DependsOnName"] = "Me.Class.ShortName";
        ["Name"] = "CWTN.Mode";
    },
    {
        ["Inverse"] = false;
        ["DependsOnValue"] = "war,shd,clr,shm,mag,bst,mnk,ber,rog,enc";
        ["Type"] = "Observed";
        ["DependsOnName"] = "Me.Class.ShortName";
        ["Name"] = "CWTN.Paused";
    },
    {
        ["Type"] = "Observed";
        ["Name"] = "Me.CurrentFavor";
        ["Inverse"] = false;
    },
    {
        ["Type"] = "Observed";
        ["Name"] = "Me.TributeActive";
        ["Inverse"] = false;
    },
    {
        ["Type"] = "Observed";
        ["Name"] = "Me.TributeTimer";
        ["Inverse"] = false;
    }
}

library['Columns'] = {
    {
        ["InZone"] = false;
        ["Ascending"] = false;
        ["Type"] = "property";
        ["Percentage"] = false;
        ["Name"] = "CWTN Mode";
        ["Properties"] = {
            ["all"] = "CWTN.Mode";
        };
    },
    {
        ["InZone"] = false;
        ["Name"] = "CWTN Paused";
        ["Ascending"] = false;
        ["Type"] = "property";
        ["Percentage"] = false;
        ["Properties"] = {
            ["all"] = "CWTN.Paused";
        };
    },
    {
        ["InZone"] = false;
        ["Ascending"] = true;
        ["Type"] = "property";
        ["Percentage"] = false;
        ["Name"] = "Favor";
        ["Properties"] = {
            ["all"] = "Me.CurrentFavor";
        };
    },
    {
        ["InZone"] = false;
        ["Ascending"] = false;
        ["Type"] = "property";
        ["Percentage"] = false;
        ["Name"] = "Tribute";
        ["Properties"] = {
            ["all"] = "Me.TributeActive";
        };
    },
    {
        ["InZone"] = false;
        ["Ascending"] = false;
        ["Type"] = "property";
        ["Percentage"] = false;
        ["Name"] = "TributeTimer";
        ["Properties"] = {
            ["all"] = "Me.TributeTimer";
        };
    }
}

return library