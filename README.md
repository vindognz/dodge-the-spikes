# Dodge The Spikes

A reflex game where your only goal is to not die.

## What?
Spikes fly at you from both sides of the screen. Jump over them. Don't get hit. 

## How to play?
- **Move**: Arrows keys or WASD
- **Jump**: Space / W / Up arrow (you can hold to bounce)
- Every 10 spikes is a new level, and every level is faster

## Features
- Levels: speed, spawn rate and danger zones all scale with your level
- Danger zones (and at higher levels, two at once)
- A squishy 'jelly' ball that stretches, splats and shatters on spikes
- Firefly background, written as a shader
- Global leaderboard (shows best score per play)
- Everything is drawn in code (no image assets!)

## Play
[Play in browser](https://spikes.vindognz.hackclub.app) *(WebGL)*

## Built with
- [Godot 4.7](https://godotengine.org)
- [Supabase](https://supabase.com) for the leaderboard backend
- Hosted on [HackClub Nest](https://hackclub.app)

## Running locally
Open the project in Godot 4.7 and hit play.

For the web build, run serve.py and open http://localhost:5001

## todo based on playtesting
- sfx
- score and highscore on the game over screen
- polish