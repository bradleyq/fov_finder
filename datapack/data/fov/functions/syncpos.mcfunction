tag @s add cc
execute at @s positioned ^ ^ ^-1.2 run tag @p add cp
execute as @p[tag=cp] at @s anchored eyes positioned ^ ^ ^1.2 run tp @e[tag=callibrator,tag=cc] ~ ~-0.925 ~
execute store result entity @e[tag=callibrator,tag=cc,limit=1] Pose.Head[0] float 1 run data get entity @p[tag=cp] Rotation[1]
tag @a[tag=cp] remove cp
tag @e[tag=cc] remove cc
