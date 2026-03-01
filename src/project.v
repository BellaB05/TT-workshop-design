/*
 * 8x8 Heart Columns VGA Generator
 * Modified from original stripes example
 */

`default_nettype none

module tt_um_BellaB05_Hearts(
  input  wire [7:0] ui_in,    // Dedicated inputs
  output wire [7:0] uo_out,   // Dedicated outputs
  input  wire [7:0] uio_in,   // IOs: Input path
  output wire [7:0] uio_out,  // IOs: Output path
  output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
  input  wire       ena,      // always 1 when the design is powered, so you can ignore it
  input  wire       clk,      // clock
  input  wire       rst_n     // reset_n - low to reset
);

  // VGA signals
  wire hsync;
  wire vsync;
  wire [1:0] R;
  wire [1:0] G;
  wire [1:0] B;
  wire video_active;
  wire [9:0] pix_x;
  wire [9:0] pix_y;

  // TinyVGA PMOD
  assign uo_out = {hsync, B[0], G[0], R[0], vsync, B[1], G[1], R[1]};

  // Unused outputs assigned to 0.
  assign uio_out = 0;
  assign uio_oe  = 0;

  // Suppress unused signals warning
  wire _unused_ok = &{ena, ui_in, uio_in};

  reg [9:0] counter;

  hvsync_generator hvsync_gen(
    .clk(clk),
    .reset(~rst_n),
    .hsync(hsync),
    .vsync(vsync),
    .display_on(video_active),
    .hpos(pix_x),
    .vpos(pix_y)
  );
  
  wire [9:0] moving_x = pix_x + counter;

  assign R = (video_active && heart_pixel && column_enable) ? 2'b11 : 2'b00;
  assign G = (video_active && heart_pixel && column_enable) ? 2'b01 : 2'b00;
  assign B = (video_active && heart_pixel && column_enable) ? 2'b10 : 2'b00;
  
  always @(posedge vsync, negedge rst_n) begin
    if (~rst_n) begin
      counter <= 0;
    end else begin
      counter <= counter + 1;
    end
  end

  // 8x8 Tile Coordinates
  wire [2:0] tile_x = moving_x[2:0];  // position inside 8-wide tile
  wire [2:0] tile_y = pix_y[2:0];     // position inside 8-high tile

  // Column spacing (every 16 pixels)
  wire column_enable = (moving_x[4:3] == 2'b00);
  // change spacing by adjusting which upper bits are checked

  // 8x8 Heart Bitmap
  reg heart_pixel;

  always @(*) begin
    case (tile_y)
      3'd0: heart_pixel = (8'b01100110 >> (7 - tile_x)) & 1;
      3'd1: heart_pixel = (8'b11111111 >> (7 - tile_x)) & 1;
      3'd2: heart_pixel = (8'b11111111 >> (7 - tile_x)) & 1;
      3'd3: heart_pixel = (8'b11111111 >> (7 - tile_x)) & 1;
      3'd4: heart_pixel = (8'b01111110 >> (7 - tile_x)) & 1;
      3'd5: heart_pixel = (8'b00111100 >> (7 - tile_x)) & 1;
      3'd6: heart_pixel = (8'b00011000 >> (7 - tile_x)) & 1;
      default: heart_pixel = 1'b0;
    endcase
  end


  // Suppress unused signals warning
  wire _unused_ok_ = &{moving_x, pix_y};

endmodule
