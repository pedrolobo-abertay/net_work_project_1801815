function _draw(self)

  love.graphics.setColor(1.0, 1.0, 0.5)

  love.graphics.circle("fill", self.pos.x, self.pos.y, self.radius)

end

function _update(self, dt)

  self.pos.x = self.pos.x + self.direction.x * dt * self.speed
  self.pos.y = self.pos.y + self.direction.y * dt * self.speed

  if self.pos.x + self.radius < 0 or self.pos.x - self.radius  > SCREEN_SIZE.x or
     self.pos.y + self.radius < 0 or self.pos.y - self.radius > SCREEN_SIZE.y then
    self.kill = true
  end
end

function _create_projectile(pos, direction, owner)

  local projectile = {
    kill = false,
    radius = 10,
    speed = 500,
    pos = {x = pos.x, y = pos.y},
    type = "projectile",
    direction = {x = direction.x, y = direction.y},
    owner = owner,

    update = _update,
    draw = _draw,
  }
  return projectile

end

return _create_projectile
