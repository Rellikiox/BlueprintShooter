-- Base Entity

Entity = class("Entity")

Entity.static.next_id = 0

function Entity:initialize()
	self.id = Entity.next_id
	Entity.next_id = Entity.next_id + 1	
	
	
end
