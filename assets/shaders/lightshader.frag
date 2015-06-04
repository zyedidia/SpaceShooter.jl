uniform vec2 frag_LightOrigin;	// The light's position

uniform vec3 frag_LightColor; 	// Its colour

uniform float frag_LightAttenuation;	// We could call this its luminosity

uniform vec2 frag_ScreenResolution; // We need this because SFML reverses the Y axis. Note: we could just be using a single float for the Y resolution. 


void main()

{		

	vec2 baseDistance =  gl_FragCoord.xy; // Storing our pixel's position

	baseDistance.y = frag_ScreenResolution.y-baseDistance.y; // Fixing the reversed Y axis

	vec2 distance=frag_LightOrigin - baseDistance; // Getting the distance between our light and the pixel, as a 2D vector

	float linear_distance = length(distance); // Getting the linear distance through a normalization 

	float attenuation=1.0/( frag_LightAttenuation*linear_distance + frag_LightAttenuation*linear_distance);	// The closer our pixel is to the light source, the smaller the light attenuation will be. 

	vec4 lightColor = vec4(frag_LightColor, 1.0);

	vec4 color = vec4(attenuation, attenuation, attenuation, 1.0) * lightColor; // We multiply our light's colour with the attenuation vector, which will give us the final 'luminosity' of our pixel. 

	gl_FragColor=color; // We give our pixel its final colour. 
}
