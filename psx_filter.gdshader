shader_type canvas_item;

// โยนตัวแปรออกไปให้ปรับค่าได้ใน Inspector หน้า Godot
uniform int pixel_size : hint_range(1, 16) = 4;      // ยิ่งเลขเยอะ ภาพยิ่งแตกเป็นบล็อก
uniform int color_depth : hint_range(1, 256) = 16;   // ยิ่งเลขน้อย สียิ่งถูกบีบให้ดูเก่า

// คำสั่งดึงภาพ 3D จากหลังกล้องมาใช้ (filter_nearest คือหัวใจที่ทำให้รอยหยักคมกริบแบบ PS1)
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
	// 1. Pixelation (ลดทอนความละเอียดพิกัดหน้าจอ)
	// เอาพิกัดหน้าจอมาหารด้วยขนาดพิกเซลที่ตั้งไว้ แล้วปัดเศษทิ้ง (floor) เพื่อสร้างเป็นกริดหยาบๆ
	vec2 size = vec2(textureSize(screen_texture, 0)) / float(pixel_size);
	vec2 pixelated_uv = floor(SCREEN_UV * size) / size;
	
	// 2. ดึงสีภาพต้นฉบับจากพิกัดกริดที่หยาบแล้ว
	vec4 color = texture(screen_texture, pixelated_uv);
	
	// 3. Color Quantization (ลดทอนความละเอียดเฉดสี)
	// ปัดเศษทศนิยมของค่าสี เพื่อบีบให้เฉดสีมีจำนวนจำกัดแบบเกมสมัยก่อน (Color Banding)
	color.rgb = floor(color.rgb * float(color_depth)) / float(color_depth);
	
	// 4. พ่นสีที่ประมวลผลแล้วออกสู่หน้าจอ
	COLOR = color;
}