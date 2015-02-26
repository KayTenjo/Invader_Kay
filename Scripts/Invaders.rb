


module Inv_Settings

#-------------------------------------------------------------------------------
#  Opciones del script
#-------------------------------------------------------------------------------  


  #---------------------#
  # OPCIONES DE JUGADOR #
  #---------------------#

    VIDAS_INICIALES = 3
    VELOCIDAD_JUGADOR = 5
    VELOCIDAD_DISPARO_JUGADOR= 8

  #----------------------#
  # OPCIONES DE ENEMIGOS #
  #----------------------#

    ENEMIGO_HP = 1
    VELOCIDAD_DISPARO_ENEMIGO= 4
    VELOCIDAD_ENEMIGO= 2


  #----------------------#
  # OTRAS OPCIONES       #
  #----------------------#

    PUNTOS_VIDA_EXTRA=100
    ANCHO_PUNTAJE= 50
    LARGO_PUNTAJE= 100


end

# end Inv_Settings

#-------------------------------------------------------------------------------
#  CACHE
#-------------------------------------------------------------------------------
module Cache
  def self.cargar(filename)
    load_bitmap("Graphics/Invaders/", filename)
  end
end # module Cache


class K_Invaders_Scene <Scene_Base
  
  def start
    #$game_system.save_bgm #No se que es tengo que averiguar, parece que es para guardar el tema que estaba sonando
    super
    #SceneManager.clear
    #Graphics.freeze
    initialize_game
  end
 
  def initialize_game
    play_bgm
    init_variables
    create_backgroud
    create_sprites
    create_stats
  end

  def play_bgm

    @bgm = RPG::BGM.new("battle_corneria",100,100)
    @player_shoot_se =RPG::SE.new("player_shoot",100,100)
    @impact =RPG::SE.new("impact",100,100)
    @bgm.play

  end
  
  def init_variables

    ###### Globables###

    $puntaje= 0
    $vidas=Inv_Settings::VIDAS_INICIALES 

    ######


    @array_disparos_jugador =Array.new
    @array_enemigos=Array.new
    @cont_disparos=0
    @cont_respawn=0
    @puedo_disparar= true
    @estoy_vivo = true
    @array_disparos_enemigos = Array.new
    @game_over=false

  end

  def create_sprites
    
    @player_sprite = Sprite_Player.new(@viewport1)
    @array_enemigos.push(Sprite_Enemy.new(@viewport2,1))

  end
  
  def create_backgroud

    @background = Plane.new
    @background.bitmap = Cache.cargar("backdrop")

  end

  def create_stats

    @window_score = Window_Score.new
    @window_score

  end
    

  #--------------------------------------------------------------------------
  # * Post-Start Processing
  #--------------------------------------------------------------------------
  def post_start
    super()
  end
  #--------------------------------------------------------------------------
  # * Determine if Scene Is Changing
  #--------------------------------------------------------------------------
  def scene_changing?
    super()
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super()

    self.return if Input.press?(:B)

    if @game_over

      initialize_game if Input.press?(:A)

    else

      if @estoy_vivo

        if Input.press?(:A) && @puedo_disparar

          @player_shoot_se.play
          @array_disparos_jugador.push(Sprite_Shooting.new(@viewport3,@player_sprite.x + @player_sprite.ancho/2, @player_sprite.y,true))
          @cont_disparos =0 
          @puedo_disparar = false

        end

        @player_sprite.update
        update_collisions

      else

        @cont_respawn+=1

        if @cont_respawn==120
          @player_sprite = Sprite_Player.new(@viewport1)
          @estoy_vivo=true
          @cont_respawn=0

        end

      
      end

      @cont_disparos+= 5

      if @cont_disparos == 30
        @puedo_disparar= true

      end

    end

    update_enemies
    update_shoots
    @background.oy -= 5

  end

  def update_enemies
    @array_enemigos.each_with_index { |e, i| 

      e.update_position

      if e.limite_disparos>=60
        @array_disparos_enemigos.push(Sprite_Shooting.new(@viewport4,e.x + e.ancho/2, e.y,false))
        e.limite_disparos=0
      else 
        e.limite_disparos+=2
      end 
    }

  end
  
  def update_shoots

    @array_disparos_jugador.each_with_index { |e, i| 
      e.update_position 
    }

    @array_disparos_enemigos.each_with_index { |e, i| 
      e.update_position 
    }


  end

  def update_collisions
    @array_indices_enemigos =Array.new
    @array_indices_disparos =Array.new
    @array_indices_disparos_enemigos =Array.new
    @jugador_disparado = false
    
    @array_enemigos.each_with_index { |enemigo, index_e| 
      next if enemigo.nil?
      @array_disparos_jugador.each_with_index {|disparo,index_d|
        next if (disparo.nil? or enemigo.nil?)
        if (disparo.collision?(enemigo))

          # enemigo.dispose
          # disparo.dispose
          # @array_disparos_jugador[index_d]= nil
          # @array_enemigos[index_e] = nil
          @array_indices_enemigos.push(index_e)
          @array_indices_disparos.push(index_d)
          
        end
      }
    }

    @array_disparos_enemigos.each_with_index { |disparo, index_d| 
      if (disparo.collision?(@player_sprite.hitbox))

        @array_indices_disparos_enemigos.push(index_d)
        @jugador_disparado = true
        
      end
      }

    @array_enemigos.each_with_index { |enemigo, index_e| 

      if(enemigo.collision?(@player_sprite))
        @jugador_disparado =true;
        @array_indices_enemigos.push(index_e)
        
      end

    }


    @array_indices_enemigos.each { |e| 

      @array_enemigos[e].dispose
      @array_enemigos[e] = nil
      @impact.play
      $puntaje += 1
      @window_score.refresh

    }
    @array_indices_disparos.each { |e| 

      @array_disparos_jugador[e].dispose
      @array_disparos_jugador[e] = nil
     }

    @array_indices_disparos_enemigos.each { |e| 

      @array_disparos_enemigos[e].dispose
      @array_disparos_enemigos[e] = nil
     }

    if @jugador_disparado
    
      @player_sprite.dispose
      @impact.play
      $vidas-=1
      @window_score.refresh

      @estoy_vivo = false

      if $vidas==0
      
        @game_over=true

        game_over_text="Game Over"
        cx = text_size(game_over_text).width
        draw_text(x, y,cx,line_height, game_over_text, 0)
      end
     
    end

    @array_enemigos.compact!
    @array_disparos_jugador.compact!
    @array_disparos_enemigos.compact!

  end


  #--------------------------------------------------------------------------
  # * Update Frame (Basic)
  #--------------------------------------------------------------------------
  def update_basic
    super()
  end
  #--------------------------------------------------------------------------
  # * Pre-Termination Processing
  #--------------------------------------------------------------------------
  def pre_terminate
  end
  #--------------------------------------------------------------------------
  # * Termination Processing
  #--------------------------------------------------------------------------
  def terminate
    Graphics.freeze
    dispose_all_windows
    dispose_main_viewport
  end
    
end #K_Invaders_Scene

class Sprite_Player < Sprite
  
  def initialize(viewport)
    super(viewport)
    @num_sprites = 3
    init_position
  end
   
  def init_position
    setup_player_image
    setup_hitbox
  end
 
  def dispose
    super
    @hitbox.dispose

  end
 
  def update
    super
    update_src_rect
    update_position
  end
   
  def setup_player_image
    @sprite_rect = 1
    @velocidad_jugador = Inv_Settings::VELOCIDAD_JUGADOR
    self.bitmap = Cache.cargar("player")
    self.src_rect= Rect.new(@sprite_rect * ancho, 0, ancho, largo)
    self.x = Graphics.width / 2
    #self.y = Graphics.height - (largo / 4)
    self.y = 320
     
    #@player_sprite.src_rect= Rect.new(0,0,@player_sprite.bitmap.width/3, @player_sprite.bitmap.height)

    #@sprite_wil = bitmap.width / 3 
    #self.src_rect.set(@cell * @cw, 0, @cw, height)
    #self.ox = @cw / 2
    #self.oy = height
    #self.x = Graphics.width / 2
    #self.y = Graphics.height - height / 4
  end

  def setup_hitbox

    @hitbox = HitBox.new(@viewport2,self.x, self.y,ancho,largo,true)

  end
 
  def ancho
    self.bitmap.width / @num_sprites
  end
  
  def largo
    self.bitmap.height
  end

  def hitbox
    @hitbox
  end
   
  def update_src_rect
    nueva_posicion = @sprite_rect * ancho
    self.src_rect.set(nueva_posicion, 0, ancho, largo)
  end
   
  def update_position
    
    if Input.press?(:LEFT) && Input.press?(:UP)
      @sprite_rect = 0
      if self.x >0  && self.y >0
        self.x -= @velocidad_jugador
        self.y -= @velocidad_jugador
        @hitbox.update_position(- @velocidad_jugador, - @velocidad_jugador)
      end

    elsif Input.press?(:LEFT) && Input.press?(:DOWN)
      @sprite_rect = 0
      if self.x >0  && self.y < Graphics.height - largo
        self.x -= @velocidad_jugador
        self.y += @velocidad_jugador
        @hitbox.update_position(- @velocidad_jugador, @velocidad_jugador)
      end

    elsif Input.press?(:RIGHT) && Input.press?(:UP)
      @sprite_rect = 2
      if self.x < Graphics.width - ancho  && self.y >0
        self.x += @velocidad_jugador
        self.y -= @velocidad_jugador
        @hitbox.update_position(@velocidad_jugador, - @velocidad_jugador)
      end

    elsif Input.press?(:RIGHT) && Input.press?(:DOWN)
      @sprite_rect = 2
      if self.x < Graphics.width - ancho  && self.y < Graphics.height - largo
        self.x += @velocidad_jugador
        self.y += @velocidad_jugador
        @hitbox.update_position(@velocidad_jugador, @velocidad_jugador)
      end

    elsif Input.press?(:LEFT) && !Input.press?(:RIGHT)
      @sprite_rect = 0
      if self.x >0
        self.x -= @velocidad_jugador  
        @hitbox.update_position(-@velocidad_jugador,0)
      end

    elsif Input.press?(:RIGHT) && !Input.press?(:LEFT)
      @sprite_rect = 2
      if self.x < Graphics.width - ancho
        self.x += @velocidad_jugador 
        @hitbox.update_position(@velocidad_jugador,0)
      end

    elsif Input.press?(:UP) && !Input.press?(:DOWN)
      @sprite_rect=1
      if self.y >0
        self.y -= @velocidad_jugador 
        @hitbox.update_position(0, -@velocidad_jugador)
      end

    elsif Input.press?(:DOWN) && !Input.press?(:UP)
      @sprite_rect=1
      if self.y < Graphics.height - largo
        self.y += @velocidad_jugador 
        @hitbox.update_position(0, @velocidad_jugador)
      end

    else
      @sprite_rect = 1
    end
  end
end # Sprite_Player < Sprite


class Sprite_Enemy < Sprite

  def initialize(viewport,nivel)
    super(viewport)
    @nivel = nivel
    init_position

  end
   
  def init_position
    setup_enemy_image
    setup_hitbox
  end
 
  def dispose
    super
  end
 
  def update
    super
    #update_src_rect
    update_position
  end
   
  def setup_enemy_image

    @contador_mov=0
    @tipo_mov= 0
    @limite_disparos=0
    #@sprite_rect = 1
    @velocidad_jugador =5
    self.bitmap = Cache.cargar("malos")
    self.src_rect= Rect.new(71, 548, 32, 21)
    self.x = Graphics.width / 2
    #self.y = Graphics.height - (largo / 4)
    self.y = -10
     
    #@player_sprite.src_rect= Rect.new(0,0,@player_sprite.bitmap.width/3, @player_sprite.bitmap.height)

    #@sprite_wil = bitmap.width / 3 
    #self.src_rect.set(@cell * @cw, 0, @cw, height)
    #self.ox = @cw / 2
    #self.oy = height
    #self.x = Graphics.width / 2
    #self.y = Graphics.height - height / 4
  end

  def setup_hitbox

    #@hitbox = HitBox.new(@viewport2,self.x, self.y,self.bitmap.height,self.bitmap.width,false)
  end

  def explote
    dispose
  end
 
  #def ancho
  #  self.bitmap.width / @num_sprites
  #end
  
  #def largo
  #  self.bitmap.height
  #end
   
  #def update_src_rect
    #ueva_posicion = @sprite_rect * ancho
   # self.src_rect.set(nueva_posicion, 0, ancho, largo)
 # end
  def ancho
   # self.bitmap.width / @num_sprites
   return 25
  end
  
  def largo
    #self.bitmap.height
    return 25
  end

  def update_position
    if @tipo_mov ==0
      self.x +=Inv_Settings::VELOCIDAD_ENEMIGO
      self.y +=Inv_Settings::VELOCIDAD_ENEMIGO
      @contador_mov +=1
    end

    if @tipo_mov ==1
      self.x -=Inv_Settings::VELOCIDAD_ENEMIGO
      self.y +=Inv_Settings::VELOCIDAD_ENEMIGO
      @contador_mov +=1
    end

    if @contador_mov==60
      if @tipo_mov ==0
        @tipo_mov =1
        @contador_mov=0
      else
        @tipo_mov =0
        @contador_mov=0
      end
    end
  end

  def limite_disparos
    @limite_disparos
  end 

  def limite_disparos=(nuevo_limite)
    @limite_disparos = nuevo_limite
  end

  def collision?(obj)

    if self.x.between?(obj.x, obj.x + obj.ancho) and self.y.between?(obj.y, obj.y + obj.largo)
      return true
    else
      return false
    end
  end

end # Sprite_Enemy < Sprite

class Sprite_Shooting < Sprite

  def initialize(viewport,x,y,player)
    super(viewport)
    @num_sprites = 3
    @x = x
    @y = y
    @player = player
    init_position
  end
   
  def init_position
    setup_shoot_image
  end
 
  def dispose
    super
  end
 
  def update
    super
   # update_src_rect
    update_position
  end
   
  def setup_shoot_image

    if @player
      self.bitmap = Cache.cargar("lazers")
      self.src_rect= Rect.new(212, 31, 8, 13)
      self.x = @x -  9
      self.y = @y
    else 
      self.bitmap = Cache.cargar("lazers")
      self.src_rect= Rect.new(235, 48, 8, 13)
      self.x = @x -  9
      self.y = @y
    end
  end
 
   
  def update_position

    if @player
      self.y -=Inv_Settings::VELOCIDAD_DISPARO_JUGADOR
    else 
      self.y +=Inv_Settings::VELOCIDAD_DISPARO_ENEMIGO
    end
  end

  def ancho
    #self.bitmap.width / @num_sprites
    return 15
  end
  
  def largo
    #self.bitmap.height
    return 15
  end

  def collision?(obj)

    if self.x.between?(obj.x, obj.x + obj.ancho) and self.y.between?(obj.y, obj.y + obj.largo)
      return true
    else
      return false
    end
  end

end # Sprite_Shooting < Sprite

class HitBox < Sprite

  def initialize(viewport,ox,oy,ancho,largo,player)
    super(viewport)
    @num_sprites = 3
    @x =ox
    @y = oy
    @ancho= ancho
    @largo = largo
    @player = player
    init_position
  end
   
  def init_position
    setup_hitbox
  end
 
  def dispose
    super
  end
 
  def update
    super
   # update_src_rect
    update_position
  end
   
  def setup_hitbox

    if @player
      #self.bitmap = Cache.cargar("balas")
      self.src_rect= Rect.new(194, 242, 11, 11)
      self.x = @x + @ancho/2 - self.width / 2
      self.y = @y + @largo/2 - self.height / 2
    
    else
      self.bitmap.height = @ancho
      self.bitmap.width = @largo
      self.x = @x
      self.y = @y
    end

  end
 
   
  def update_position(x,y)
    self.x += x
    self.y += y
  end

  def get_x
    self.x
  end

  def get_y
    self.y
  end

  def ancho
    @ancho
  end

  def largo
    @largo
  end

end #Hitbox



class Window_Score < Window_Base
  def initialize
    super(0, 0, Graphics.width, Graphics.height)
    self.opacity = 0
    refresh
  end
   
  def refresh()
    contents.clear
    dibujar_texto("Puntos: ", score, 0, 0, 0)
    dibujar_texto("Vidas: ", vidas, Graphics.width - 120, 0, 0)
    
  end
   
  def score
    $puntaje
  end
  def vidas
    $vidas
  end
 
  def dibujar_texto(texto, num, x, y, align)
    cx = text_size(texto).width
    draw_text(x, y,cx,line_height, texto, align)
    draw_text(x + cx, y,cx,line_height, num, align)
    
  end
   
  def open
    refresh
    super
  end
end # Window_InvaderScore < Window_Base
