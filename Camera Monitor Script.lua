
myPlayer = Space.Scene.PlayerAvatar
myObj = Space.Host.ExecutingObject

isSeated = false
seatedOn = nil

myCanvas = Space.Host.GetReference('canvas')
myCameraBar = Space.Host.GetReference('camera bar')
myCameraButton = Space.Host.GetReference('camera button')
myCameras = Space.Host.GetReference('cameras').children

cameraButtons = {}

currentCamera = 0
useCamera = false

function init()
    coroutine.yield(0)
    for c=1, #myCameras, 1 do
        local newButton = myCameraButton.Duplicate()
        newButton.Name = myCameras[c].Name
        newButton.FindInChildren("Text").UIText.Text = newButton.Name
        newButton.Parent = myCameraBar
        newButton.LocalScale = Vector.One
        newButton.UIButton.OnClick(function()
            selectCamera(c)
        end)
        newButton.Active = true
        table.insert(cameraButtons, newButton)
        coroutine.yield(0.1)
    end
    -- Make Free Cam button (camera off, essentially)
    local newButton = myCameraButton.Duplicate()
    newButton.Name = "Free Camera"
    newButton.FindInChildren("Text").UIText.Text = newButton.Name
    newButton.Parent = myCameraBar
    newButton.LocalScale = Vector.One
    newButton.UIButton.OnClick(function()
        selectCamera(0)
    end)
    newButton.Active = true
    table.insert(cameraButtons, newButton)
    -- Register watcher
    myObj.OnLateUpdate(eventOnUpdate)
end

function selectCamera(camera)
    cameraButtons[#cameraButtons].UIButton.Interactable = camera ~= 0
    for c=1, #myCameras, 1 do
        if c == camera and useCamera then
            if myCameras[c].VirtualCamera == nil then
                myCameras[c].WorldPosition = myPlayer.GameObject.WorldPosition
                myCameras[c].WorldRotation = myPlayer.GameObject.WorldRotation
            end
            myCameras[c].Active = true
        else
            myCameras[c].Active = false
        end
        cameraButtons[c].UIButton.Interactable = not myCameras[c].Active
    end
end

function eventOnUpdate()
    local lock = myPlayer.LockObject
    local seated = false;
    if lock ~= nil and lock.Seat ~= nil then
        seated = true
    end
    if seated ~= isSeated then
        isSeated = seated
        if isSeated then
            -- They weren't sitting, but now they are.
            currentCamera = 1
            -- Find out if there's another camera in use.
            local activeCam = Space.Camera.ActiveVirtualCamera
            if activeCam == nil or activeCam.Parent == nil then
                -- Only use our camera
                useCamera = true
            else
                useCamera = false
            end
        else
            -- They were sitting, but now they aren't.
            useCamera = false
            currentCamera = 0
        end
        myCanvas.Active = isSeated and useCamera
        selectCamera(currentCamera)
    end
end

Space.Host.StartCoroutine(init)
