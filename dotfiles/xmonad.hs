import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig
import System.Exit
import XMonad.Hooks.EwmhDesktops
import XMonad.Layout.NoBorders
import XMonad.Layout.Named
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Actions.CopyWindow
import XMonad.StackSet as W
import XMonad.Layout.MouseResizableTile
import XMonad.Layout.PositionStoreFloat
import XMonad.Layout.NoFrillsDecoration
import XMonad.Layout.BorderResize
import System.IO
import qualified Data.Map as M
import XMonad.Layout.Monitor



main = do
    xmonad $ ewmh defaultConfig
        { manageHook = manageDocks <+> manageHook defaultConfig
        , layoutHook = avoidStruts $ myLayouts 
        , modMask = mod4Mask
        , keys = keys defaultConfig
        , focusFollowsMouse = False
        , focusedBorderColor = "#cb4b16"
        , normalBorderColor = "#657b83"
        , borderWidth = 2
        , terminal = "kitty"
        }
        `removeKeys` [(mod4Mask .|. shiftMask ,xK_q)] 
        `additionalKeys` keysToAdd
        
 


keysToAdd  = [ ((mod4Mask, xK_a), sequence_ $ [windows $ copy i | i <- XMonad.workspaces defaultConfig]) -- copy window to all workspaces
              ,  ((mod4Mask .|. shiftMask, xK_a), windows $ kill8) -- remove window from all workspaces except the current one
              ,  ((mod4Mask, xK_u), sendMessage ShrinkSlave)
              ,  ((mod4Mask, xK_i), sendMessage ExpandSlave)
	      ,  ((mod4Mask, xK_r), broadcastMessage ToggleMonitor >> refresh)
              ] ++ (programShortcuts ) ++ (quittingKeys )

keysForMoving x = [((m .|. mod4Mask, k), windows $ f i)
                   | (i, k) <- zip (XMonad.workspaces x) [xK_1 ..]
                   , (f, m) <- [(W.view, 0), (W.shift, shiftMask), (copy, shiftMask .|. controlMask)]]

programShortcuts  = [((mod4Mask, xK_n), spawn "firefox")]

quittingKeys  = [ ((mod4Mask .|. shiftMask, xK_q), spawn "cbpp-exit")
                , ((mod4Mask .|. shiftMask .|. mod1Mask, xK_q), io (exitWith ExitSuccess))
                ]



myLayouts = avoidStruts $ ( smartBorders $ (
                            tiled1 |||
                            tiled2 |||
                            fullscreen |||
			    floating1 )
                          )

floating1 = borderResize $ positionStoreFloat 
tiled1 = mouseResizableTile
tiled2 = mouseResizableTileMirrored
fullscreen = Full


kill8 ss | Just w <- W.peek ss = (W.insertUp w) $ W.delete w ss | otherwise = ss


