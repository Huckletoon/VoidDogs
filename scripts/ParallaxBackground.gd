extends ParallaxBackground

onready var layer0 = get_node("layer0")
onready var layer1 = get_node("layer1")
onready var layer2 = get_node("layer2")
onready var layer3 = get_node("layer3")
onready var layer4 = get_node("layer4")

var rng = RandomNumberGenerator.new()
var base = Image.new()
var stars1 = Image.new()
var stars2 = Image.new()
var stars3 = Image.new()
var stars4 = Image.new()

const WIDTH = 4000
const HEIGHT = 4000
const PAD = 10

func _ready():
	rng.randomize()
	base.create(WIDTH, HEIGHT, false, Image.FORMAT_RGBA8)
	base.fill(Color(0,0,0,0))
	
	stars1.copy_from(base)
	stars2.copy_from(base)
	stars3.copy_from(base)
	stars4.copy_from(base)
	generateStars(stars1, 1)
	generateStars(stars2, 2)
	generateStars(stars3, 3)
	generateStars(stars4, 3)
	var stars1Text = ImageTexture.new()
	var stars2Text = ImageTexture.new()
	var stars3Text = ImageTexture.new()
	var stars4Text = ImageTexture.new()
	stars1Text.create_from_image(stars1)
	stars2Text.create_from_image(stars2)
	stars3Text.create_from_image(stars3)
	stars4Text.create_from_image(stars4)
	layer1.get_node("Sprite").texture = stars1Text
	layer2.get_node("Sprite").texture = stars2Text
	layer3.get_node("Sprite").texture = stars3Text
	layer4.get_node("Sprite").texture = stars4Text
	
	pass
	
func generateStars(image, maxRadius):
	var count = rng.randi_range(40, 160)
	image.lock()
	for x in range(count):
		var pos = Vector2(rng.randi_range(PAD, WIDTH-PAD), rng.randi_range(PAD, HEIGHT-PAD))
		var radius = rng.randi_range(1,maxRadius)
		# without radius
		image.set_pixel(pos.x, pos.y, Color(1,1,1,1))
		# with radius
		for i in range(radius * 2) :
			# i acts as x coordinate
			if i != 0:
				#var tempX = 
				var tempY = ceil(radius * sin(PI/2.0/i))
				for y in range(tempY + 1):
					image.set_pixel(pos.x + i, pos.y - y, Color.white)
					image.set_pixel(pos.x + i, pos.y + y, Color.white)
					image.set_pixel(pos.x - i, pos.y - y, Color.white)
					image.set_pixel(pos.x - i, pos.y + y, Color.white)
			else:
				var tempY = ceil(radius * sin(PI/2.0))
				for y in range(tempY + 1):
					image.set_pixel(pos.x, pos.y - y, Color.white)
					image.set_pixel(pos.x, pos.y + y, Color.white)
		
	image.unlock()
	pass